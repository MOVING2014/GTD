// AddTaskComponent.ets
import { ContextModel, ProjectModel, ReminderModel, TaskModel } from '../models/IModels';
import { formatDateToChinese, parseDate } from '../common/utils';
import { Constants } from '../common/Constants';
import hilog from '@ohos.hilog';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct EditTaskComponent {

  @Consume gtdController: GTDController;
  @Consume currentEditingTask: TaskModel
  @State dueDateString: string = ''

  @State selectedContext: ContextModel| { id: -1, name : '' }  = { id: -1, name : '' } ;
  @State selectedProject: ProjectModel| { id: -1, name : '' }  = { id: -1, name : '' } ;



  onConfirm: (task: TaskModel) => void;
  onCancel: () => void;

  aboutToAppear() {
    this.dueDateString = formatDateToChinese(this.currentEditingTask.dueDate)|| '';
    this.selectedContext = this.currentEditingTask.context || { id: -1, name : '' } ;
    this.selectedProject = this.currentEditingTask.project || { id: -1, name : '' } ;

  }

  @Builder DateSelector() {
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text(this.dueDateString ? this.dueDateString:'日期')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(Color.Black)
      .borderRadius(5)
      .onClick(() => this.showDatePicker())
    }
    .margin({right:5})
  }

  @Builder FlagSelector(){
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('flag')
            .fontSize(16)
            .fontColor(this.currentEditingTask.flagged ? Color.White : Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(this.currentEditingTask.flagged ? '#007DFF' : Color.Black)
      .borderRadius(5)
      .onClick(
        () => {
          this.currentEditingTask.flagged = !this.currentEditingTask.flagged;

        }
      )
    }
    .margin({right:5})
  }

  @Builder ContextSelector(){
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text(this.selectedContext.id != -1 ? this.selectedContext.name : '场景')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(Color.Black)
      .borderRadius(5)
      .bindMenu(this.contextMenuBuilder)

    }
    .margin({right:5})
  }

  @Builder contextMenuBuilder() {
    Menu() {
      MenuItem({ content: '无场景' })
        .onClick(() => {
          this.selectedContext =  { id: -1, name : '' } ;
          // 这里可以添加清除选择后的逻辑
        })

      ForEach(Object.values(this.gtdController.contextCache), (context: ContextModel) => {
        MenuItem({ content: context.name })
          .onClick(() => {
            this.selectedContext = context
            // 这里可以添加选择 context 后的逻辑，比如更新任务的 context
          })

      })
    }
  }

  @Builder ProjectSelector(){
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text(this.selectedProject.id !=-1 ? this.selectedProject.name : '项目')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .bindMenu(this.ProjectMenuBuilder)
      .height(30)
      .backgroundColor(Color.Black)
      .borderRadius(5)
      .onClick(
        () => {}
      )
    }
    .margin({right:5})
  }


  @Builder ProjectMenuBuilder() {
    Menu() {
      MenuItem({ content: '无项目' })
        .onClick(() => {
          this.selectedProject =  { id: -1, name : '' } ;
          // 这里可以添加清除选择后的逻辑
        })

      ForEach(Object.values(this.gtdController.projectCache), (project: ProjectModel) => {
        MenuItem({ content: project.name })
          .onClick(() => {
            this.selectedProject = project
            // 这里可以添加选择 context 后的逻辑，比如更新任务的 context
          })

      })
    }
  }



  @Builder Sender(){
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('确认')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(Color.Blue)
      .borderRadius(5)
      .onClick(() => {
        hilog.debug(0x009, 'AddTask', `onclick : ${this.selectedProject.name}`)
        const task: TaskModel = {
          ...this.currentEditingTask,
          dueDate: parseDate(this.dueDateString),
          createdDate: new Date(), // 为新任务设置创建日期
          project: this.selectedProject.id != -1 ? this.selectedProject : undefined,
          context: this.selectedContext.id != -1 ? this.selectedContext : undefined,
          modifyTime: new Date()
        };
        hilog.debug(0x009, 'AddTask', `onclickprojectId : ${this.selectedProject.name}`)
        hilog.debug(0x009, 'EditTasks',`${JSON.stringify(task)}`)

        this.onConfirm(task);
      })
    }
  }





  private showDatePicker() {
    let currentDate = new Date()
    DatePickerDialog.show({
      start: new Date(),
      end: new Date('2100-12-31'),
      selected: currentDate,
      onAccept: (value: DatePickerResult) => {
        let newDate = new Date(value.year, value.month, value.day);
        // this.dueDateString = formatDateToChinese(newDate);
        this.dueDateString = formatDateToChinese(newDate) // 这里面不能赋值给任何 @State 类变量
        hilog.debug(0x001, 'AddTask',`dueDateString: ${this.dueDateString}, this.dueDate: ${newDate.toString()}`)
      },
      onCancel: () => {
        this.dueDateString = '';
        console.info('DatePicker canceled')
      }
    })

  }

  build() {
    Column() {

      Row() {
        TextInput({
          placeholder: '准备做什么？',
          text: this.currentEditingTask.title
        })
          .width('100%')
          .height(40)
          .borderRadius(0)
          .onChange((value: string) => {
            this.currentEditingTask.title = value;
          })
      }
      .alignSelf(ItemAlign.Start)



      Row() {
        TextInput({
          placeholder: '描述？',
          text: this.currentEditingTask.description
        })
          .width('100%')
          .height(40)
          .borderRadius(0)
          .fontColor(Color.Gray)
          .onChange((value: string) => {
            this.currentEditingTask.description = value;
          })
      }
      .alignSelf(ItemAlign.Start)



      Row() {
        // 1. 日期时间
        // 2. flaged
        // 3. Context
        // 4. project
        // 5. 发送按钮
        this.DateSelector()
        this.FlagSelector()
        this.ContextSelector()
        this.ProjectSelector()
        Blank()
        this.Sender()

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({top:10})

      Divider()
        .strokeWidth(0.5)
        .margin({top:10, bottom:10})
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)

  }
}
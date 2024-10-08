// AddTaskComponent.ets
import { ContextModel, ProjectModel, ReminderModel, TaskModel } from '../models/IModels';
import { formatDateToChinese, parseDate } from '../common/utils';
import { Constants } from '../common/Constants';
import hilog from '@ohos.hilog';
import { GTDController } from '../viewmodel/GTDController';
import window from '@ohos.window';
import display from '@ohos.display';
import inputMethod from '@ohos.inputMethod';




@Component
export struct AddTaskComponent {
  private context: Context;
  @State keyboardHeight: number = 0;
  @State componentElevation: number = 0;
  @Link projects:ProjectModel[];


  @State title: string = '';
  @State description: string = '';
  // @State dueDate: Date |undefined = undefined; //@State 不能修饰Date变量
  @State isCompleted: boolean = false;
  @State priority: 'Low' | 'Medium' | 'High'|'None'  = 'None';
  @State projectId: number  = -1;
  @State contextId: number  = -1;
  @State flagged: boolean = false;
  @State reminder: ReminderModel | { id: -1, name : '', time: Date } = { id: -1, name : '',time: new Date(0)  };
  @Consume currentEditingTask: TaskModel;
  @Consume  gtdController: GTDController;
  @State dueDateString: string = ''

  @State selectedContext: ContextModel| { id: -1, name : '' }  = { id: -1, name : '' } ;
  @State selectedProject: ProjectModel| { id: -1, name : '' }  = { id: -1, name : '' } ;

  // formatDateToChinese(new Date());


  onConfirm: (task: TaskModel, isUpdate: boolean) => void;
  onCancel: () => void;



  private addKeyboardHeightListener() {
    window.getLastWindow(this.context, (err, windowClass) => {
      if (err.code) {
        console.error('Failed to obtain the top window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass.on('keyboardHeightChange', this.onKeyboardHeightChange.bind(this));
    });
  }

  private removeKeyboardHeightListener() {
    window.getLastWindow(this.context, (err, windowClass) => {
      if (err.code) {
        console.error('Failed to obtain the top window. Cause: ' + JSON.stringify(err));
        return;
      }
      windowClass.off('keyboardHeightChange');
    });
  }

  private onKeyboardHeightChange(height: number) {
    this.keyboardHeight = height;
    console.log(`Keyboard height changed to: ${height}`);

      // 获取屏幕高度

    try {
      const displayClass = display.getDefaultDisplaySync();
      const screenHeight = px2vp(displayClass.height);

      // 计算组件应该抬高的高度
      // 这里我们设置最大抬高高度为屏幕高度的一半
      const maxElevation = screenHeight / 2;
      this.componentElevation = Math.min(height, maxElevation);
      this.componentElevation = 50

    } catch (exception) {
      console.error('Failed to obtain the default display object. Code: ' + JSON.stringify(exception));
    }


  }

  aboutToAppear() {
    if (this.currentEditingTask.id != -1) {
      // 编辑模式：使用当前编辑的任务填充状态
      this.title = this.currentEditingTask.title;
      this.description = this.currentEditingTask.description || '';
      // this.dueDateString = this.currentEditingTask.dueDate || new Date();
      this.isCompleted = this.currentEditingTask.isCompleted;
      this.priority = this.currentEditingTask.priority ;
      this.projectId = this.currentEditingTask.projectId ;
      this.contextId = this.currentEditingTask.contextId ;
      this.flagged = this.currentEditingTask.flagged ;
      this.reminder = this.currentEditingTask.reminder;
      this.dueDateString = formatDateToChinese(this.currentEditingTask.dueDate);
      this.selectedContext = this.gtdController.contextCache[this.currentEditingTask.contextId]
      this.selectedProject = this.gtdController.projectCache[this.currentEditingTask.projectId]

      hilog.debug(0x009, 'AddTask', `currentEditingTask: ${JSON.stringify(this.currentEditingTask)}`)
      hilog.debug(0x009, 'AddTask', `currentEditingTask: ${this.projectId}`)
    }
    this.addKeyboardHeightListener();

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
            .fontColor(this.flagged ? Color.White : Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(this.flagged ? '#007DFF' : Color.Black)
      .borderRadius(5)
      .onClick(
        () => {
          this.flagged = !this.flagged;

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
          this.selectedContext = { id: -1, name : '' }
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
          this.selectedProject = { id: -1, name : '' }
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
      .height(40)
      .backgroundColor(Color.Blue)
      .borderRadius(5)
      .onClick(() => {
        hilog.debug(0x009, 'AddTask', `onclick : ${this.projectId}`)
        if(this.dueDateString === null || this.dueDateString === '' || this.dueDateString === undefined){
          this.currentEditingTask.dueDate = null
        }
        const task: TaskModel = this.currentEditingTask.id != -1
        ? {
            ...this.currentEditingTask,
            title: this.title,
            description: this.description,
            dueDate: parseDate(this.dueDateString),
            isCompleted: this.isCompleted,
            priority: this.priority,
            projectId: this.selectedProject?.id,
            contextId: this.selectedContext?.id,
            flagged: this.flagged,
            reminder: this.reminder,
            modifyTime: new Date()
          }
        : {
          id: 0, // 新任务的id设为0，让数据源来分配真正的id
          title: this.title,
          description: this.description,
          dueDate: parseDate(this.dueDateString),
          isCompleted: this.isCompleted,
          priority: this.priority,
          createdDate: new Date(), // 为新任务设置创建日期
          projectId: this.selectedProject?.id,
          contextId: this.selectedContext?.id,
          flagged: this.flagged,
          reminder: this.reminder,
          modifyTime: new Date()
        };
        hilog.debug(0x009, 'AddTask', `onclickprojectId : ${this.projectId}`)
        hilog.debug(0x009, 'EditTasks',`${JSON.stringify(task)}`)

        this.onConfirm(task, this.currentEditingTask.id != -1);
      })
    }
  }





  private showDatePicker() {
    let currentDate = new Date()

      DatePickerDialog.show({
        start: new Date('2023-01-01'),
        end: new Date('2100-12-31'),
        selected: this.currentEditingTask?.dueDate ? this.currentEditingTask?.dueDate : currentDate,
        onAccept: (value: DatePickerResult) => {
          let newDate = new Date(value.year, value.month, value.day);
          // this.dueDateString = formatDateToChinese(newDate);
          this.dueDateString = formatDateToChinese(newDate) // 这里面不能赋值给任何 @State 类变量
          hilog.debug(0x001, 'AddTask', `dueDateString: ${this.dueDateString}, this.dueDate: ${newDate.toString()}`)
        },
        onCancel: () => {
          this.dueDateString = '';
          console.info('DatePicker canceled')
        }
      })


  }

  build() {
    Column() {

      // Divider()
      //   // .strokeWidth(0.5)
      //   .margin({top:10, bottom:10})

      Row() {
        TextInput({
          placeholder: '准备做什么？',
          text: this.title
        })
          .defaultFocus(true)
          .width('85%')
          .height(40)
          .borderRadius(0)
          .onChange((value: string) => {
            this.title = value;
          })
          .key('taskinput')
          .onAppear(()=>{
            sendEventByKey('taskinput',10,'弹出键盘')
            // sendEventByKey('123',10,'弹出键盘')
          })
          .margin({right:5})
        Blank()

        this.Sender()

      }
      .alignSelf(ItemAlign.Start)
      .margin({bottom:10})
      .width('100%')

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


      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({top:10, bottom:10 })


      //
      // Row() {
      //   TextInput({
      //     placeholder: '描述？',
      //     text: this.description
      //   })
      //     .width('100%')
      //     .height(40)
      //     .borderRadius(0)
      //     .fontColor(Color.Gray)
      //     .onChange((value: string) => {
      //       this.description = value;
      //     })
      // }
      // .alignSelf(ItemAlign.Start)



      // Divider()
      //   // .strokeWidth(0.5)
      //   .margin({top:10, bottom:100})
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    // .margin({bottom:this.componentElevation})
    // .margin({bottom:-55})



  }
}
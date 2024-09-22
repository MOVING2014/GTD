// AddTaskComponent.ets
import { ReminderModel, TaskModel } from '../models/IModels';
import { formatDateToChinese, parseDate } from '../common/utils';
import { Constants } from '../common/Constants';
import hilog from '@ohos.hilog';

@Component
export struct AddTaskComponent {
  @State title: string = '';
  @State description: string = '';
  // @State dueDate: Date |undefined = undefined; //@State 不能修饰Date变量
  @State isCompleted: boolean = false;
  @State priority: 'Low' | 'Medium' | 'High'|'None'  = 'None';
  @State projectId: number | undefined = undefined;
  @State contextId: number | undefined = undefined;
  @State flagged: boolean = false;
  @State reminder: ReminderModel | undefined = undefined;
  @Consume currentEditingTask: TaskModel;
  @State dueDateString: string = ''
  // formatDateToChinese(new Date());


  onConfirm: (task: TaskModel) => void;
  onCancel: () => void;

  aboutToAppear() {
    // if (this.currentEditingTask) {
    //   // 编辑模式：使用当前编辑的任务填充状态
    //   this.title = this.currentEditingTask.title;
    //   this.description = this.currentEditingTask.description || '';
    //   this.dueDate = this.currentEditingTask.dueDate || new Date();
    //   this.isCompleted = this.currentEditingTask.isCompleted;
    //   this.priority = this.currentEditingTask.priority || null;
    //   this.projectId = this.currentEditingTask.projectId;
    //   this.contextId = this.currentEditingTask.contextId;
    //   this.flagged = this.currentEditingTask.flagged || false;
    //   this.reminder = this.currentEditingTask.reminder;
    //   this.dueDateString = formatDateToChinese(this.dueDate);
    // }
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
          Text('场景')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(Color.Black)
      .borderRadius(5)
      .onClick(
        () => {}
      )
    }
    .margin({right:5})
  }

  @Builder ProjectSelector(){
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text('项目')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .padding({ left:8, right: 8 })
      }
      .height(30)
      .backgroundColor(Color.Black)
      .borderRadius(5)
      .onClick(
        () => {}
      )
    }
    .margin({right:5})
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
        const task: TaskModel = {
          id: 0, // 新任务的id设为0，让数据源来分配真正的id
          title: this.title,
          description: this.description,
          dueDate: parseDate(this.dueDateString),
          isCompleted: this.isCompleted,
          priority: this.priority,
          createdDate: new Date(), // 为新任务设置创建日期
          projectId: this.projectId,
          contextId: this.contextId,
          flagged: this.flagged,
          reminder: this.reminder,
          modifyTime: new Date()
        };
        hilog.debug(0x001, 'EditTasks',`${JSON.stringify(task)}`)
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
          text: this.title
        })
          .width('100%')
          .height(40)
          .borderRadius(0)
          .onChange((value: string) => {
            this.title = value;
          })
      }
      .alignSelf(ItemAlign.Start)



      Row() {
        TextInput({
          placeholder: '描述？',
          text: this.description
        })
          .width('100%')
          .height(40)
          .borderRadius(0)
          .fontColor(Color.Gray)
          .onChange((value: string) => {
            this.description = value;
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
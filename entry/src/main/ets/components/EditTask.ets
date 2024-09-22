// EditTaskComponent.ets
import { ReminderModel, TaskModel } from '../models/IModels';
import { formatDateToChinese, parseDate } from '../common/utils';
import { Constants } from '../common/Constants';
import hilog from '@ohos.hilog';

@Component
export struct EditTaskComponent {
  @State title: string = '';
  @State description: string = '';
  @State dueDate: Date = new Date();
  @State isCompleted: boolean = false;
  @State priority: 'Low' | 'Medium' | 'High'  = 'Medium';
  @State projectId: number | undefined = undefined;
  @State contextId: number | undefined = undefined;
  @State flagged: boolean = false;
  @State reminder: ReminderModel | undefined = undefined;
  @Consume currentEditingTask: TaskModel;
  @State dueDateString: string = formatDateToChinese(new Date());


  onConfirm: (task: TaskModel) => void;
  onCancel: () => void;

  aboutToAppear() {
    if (this.currentEditingTask) {
      // 编辑模式：使用当前编辑的任务填充状态
      this.title = this.currentEditingTask.title;
      this.description = this.currentEditingTask.description || '';
      this.dueDate = this.currentEditingTask.dueDate || new Date();
      this.isCompleted = this.currentEditingTask.isCompleted;
      this.priority = this.currentEditingTask.priority || null;
      this.projectId = this.currentEditingTask.projectId;
      this.contextId = this.currentEditingTask.contextId;
      this.flagged = this.currentEditingTask.flagged || false;
      this.reminder = this.currentEditingTask.reminder;
      this.dueDateString = formatDateToChinese(this.dueDate);
    }
  }

  @Builder DateSelector() {
    Column() {
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Row() {
          Text(this.dueDateString)
            .fontSize(16)
            .fontColor(Color.Black)
          Blank()
          Text('▼')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height(40)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .onClick(() => this.showDatePicker())
    }
    .width('50%')
  }

  private showDatePicker() {
    let currentDate = parseDate(this.dueDateString);

    DatePickerDialog.show({
      start: new Date(),
      end: new Date('2100-12-31'),
      selected: currentDate,
      onAccept: (value: DatePickerResult) => {
        let newDate = new Date(value.year, value.month, value.day);
        this.dueDateString = formatDateToChinese(newDate);
        this.dueDate = newDate;
      },
      onCancel: () => {
        console.info('DatePicker canceled')
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('编辑任务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        this.DateSelector()
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Divider()
        .vertical(false)
        .strokeWidth(0.5)
        .margin({ top: 2, bottom: 20 })

      TextInput({
        placeholder: '任务标题',
        text: this.title
      })
        .width('90%')
        .height(40)
        .margin({ bottom: 10 })
        .onChange((value: string) => {
          this.title = value;
        })

      TextArea({
        placeholder: '任务描述',
        text: this.description
      })
        .width('90%')
        .height(80)
        .margin({ bottom: 10 })
        .onChange((value: string) => {
          this.description = value;
        })

      Row() {
        Text('优先级：')
          .fontSize(16)

        Text(this.priority.toString())
          .fontSize(16)
          .margin({ left: 10 })
      }
      .width('90%')
      .margin({ bottom: 10 })


      Divider()
        .vertical(false)
        .strokeWidth(0.5)
        .margin({ top: 2, bottom: 20 })

      Row() {
        Text('优先级：')
          .fontSize(16)
        ForEach(['Low', 'Medium', 'High'], (level) => {
          Button(level)
            .backgroundColor(this.priority === level ? '#007DFF' : '#F0F0F0')
            .fontColor(this.priority === level ? Color.White : Color.Black)
            .onClick(() => {
              this.priority = level as 'Low' | 'Medium' | 'High';
            })
        })
      }
      .width('90%')
      .margin({ bottom: 10 })

      Row() {
        Button('取消')
          .onClick(() => {
            this.onCancel();
          })
        Button('确定')
          .onClick(() => {
            const task: TaskModel = {
                  id: 0, // 新任务的id设为0，让数据源来分配真正的id
                  title: this.title,
                  description: this.description,
                  dueDate: new Date(),
                  isCompleted: this.isCompleted,
                  priority: this.priority,
                  createdDate: new Date(), // 为新任务设置创建日期
                  projectId: this.projectId,
                  contextId: this.contextId,
                  flagged: this.flagged,
                  reminder: this.reminder
                };
            hilog.debug(0x001, 'EditTasks',`${JSON.stringify(task)}`)
            this.onConfirm(task);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)

    //
    // Column(){
    //   Text("hello!!!!")
    // }
  }
}
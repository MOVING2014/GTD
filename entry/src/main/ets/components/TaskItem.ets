import hilog from '@ohos.hilog';
import { TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct TaskList {
  @State tasks: TaskModel[]|null = null;
  @Consume gtdController: GTDController;


aboutToAppear(){
  this.loadTasks()
}

  async loadTasks() {
    try {
      this.tasks = await this.gtdController.getAllTasks();
      hilog.debug(0x001,'TaskItem',`load tasks ${JSON.stringify(this.tasks[0])}`)
    } catch (error) {
      console.error('Failed to load tasks:', error);
    }
  }



  build() {
    List() {
      ForEach(this.tasks, (task: TaskModel, index:number ) => {
        ListItem() {
          // this.TaskItem(task)
          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: task.isCompleted })
              .onChange((isOn: boolean) => {
                task.isCompleted = isOn;
                this.gtdController.updateTask(task);
                this.loadTasks()
              })
              .margin({ right: 10 })

            Text(task.title)
              .fontSize(16)
              .fontColor(this.tasks[index].isCompleted ? '#888888' : '#000000')
              .decoration({ type: this.tasks[index].isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
              .flexGrow(1)

            if (task.dueDate) {
              Text(new Date(task.dueDate).toLocaleDateString())
                .fontSize(14)
                .fontColor('#888888')
            }
          }
          .width('100%')
          .padding(10)
          .borderRadius(8)
          .backgroundColor(Color.White)
          .margin({ bottom: 10 })

        }
      }, task => task.id.toString())
    }
    .width('100%')
  }
}
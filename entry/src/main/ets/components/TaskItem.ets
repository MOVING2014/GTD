import hilog from '@ohos.hilog';
import { ProjectModel, TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct TaskList {
  @State tasks: TaskModel[]|null = null;
  @State projects: ProjectModel[]|null = null;
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



  @Builder
  ProjectLabel(projectId: number) {
    if (projectId) {
      Row() {
        Text(this.gtdController.projectCache[projectId]?.name || '')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
          // .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ right: 8, top:5 })
      }
    }
  }


  @Builder
  ContextLabel(contextId: number) {
    if (contextId) {
      Row() {
        Text(this.gtdController.contextCache[contextId]?.name || '')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
          .margin({ right: 8, top:5 })
      }
    }
  }


  build() {
    List() {
      ForEach(this.tasks, (task: TaskModel, index: number) => {
        ListItem() {
          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: task.isCompleted })
              .onChange((isOn: boolean) => {
                task.isCompleted = isOn;
                this.gtdController.updateTask(task);
                this.loadTasks()
              })
              .margin({ right: 10 })
              .alignSelf(ItemAlign.Start) // 确保复选框顶部对齐

            Column() {
              Text(task.title)
                .fontSize(18)
                .fontColor(this.tasks[index].isCompleted ? '#888888' : '#000000')
                .decoration({ type: this.tasks[index].isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                .width('100%')
                .alignSelf(ItemAlign.Start)

              Row() {
                if(task.projectId){
                  this.ProjectLabel(task.projectId)

                }

                if(task.contextId){
                  this.ContextLabel(task.contextId)

                }

                if (task.dueDate) {
                  Text(new Date(task.dueDate).toLocaleDateString())
                    .fontSize(16)
                    .fontColor('#888888')
                    .margin({ top: 5 }) // 为日期添加一些顶部边距
                }



              }

            }
            .alignItems(HorizontalAlign.Start) // 确保文本左对齐
            // .flexGrow(1)
          }
          .width('100%')
          .padding(10)
          .borderRadius(8)
          .backgroundColor(Color.White)
          .margin({ bottom: 10 })
          .alignItems(VerticalAlign.Top) // 确保Row内容顶部对齐
        }
      }, task => task.id.toString())
    }
    .width('100%')
  }
}
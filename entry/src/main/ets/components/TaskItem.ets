import hilog from '@ohos.hilog';
import { Constants } from '../common/Constants';
import { formatDateToChinese, overDue } from '../common/utils';
import { ProjectModel, TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct TaskList {
  @Link tasks: TaskModel[];
  @State projects: ProjectModel[]|null = null;
  @Consume gtdController: GTDController;
  @Consume currentEditingTask: TaskModel;
  @Consume isPopupVisible: boolean;
  @State showCompletedTasks: boolean = false


aboutToAppear(){
  // this.loadTasks()
}

  // async loadTasks() {
  //   try {
  //     this.tasks = await this.gtdController.getAllTasks();
  //     hilog.debug(0x009,'TaskItem',`TaskItem load tasks ${JSON.stringify(this.tasks)}`)
  //   } catch (error) {
  //     console.error('Failed to load tasks:', error);
  //   }
  // }



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



  @Builder itemEnd(record: TaskModel) {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('EDIT')
          .fontColor(Color.White)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .onClick(() => {
        this.currentEditingTask = record;
        this.isPopupVisible = true;
        hilog.debug(0x009,'TaskItem',`TaskItem load tasks ${JSON.stringify(this.tasks[1])}`)
        // this.loadTasks()
      })
      .margin({right:10})
      // 侧滑后尾端出现的组件
      Button({ type: ButtonType.Circle }) {
        Text('DEL')
          .fontColor(Color.White)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.deleteButtonColor)
      .onClick(async () => {
        // this.controller.deleteMoodRecord(record.id)
       let result =  await this.gtdController.deleteTask(record.id)
        // this.loadTasks()
        hilog.debug(0x001,'TaskItem',`delted result ${result}`)
        hilog.debug(0x001,'TaskItem',`delted result ${JSON.stringify(await this.gtdController.getAllTasks())}`)
      })

    }
  }



  build() {
    Column() {
      List() {
        ForEach(this.tasks.filter(task => !task.isCompleted), (task: TaskModel, index: number) => {
          ListItem() {
            Row() {
              Toggle({ type: ToggleType.Checkbox, isOn: task.isCompleted })
                .onChange((isOn: boolean) => {
                  task.isCompleted = isOn;
                  task.modifyTime = new Date();
                  this.gtdController.updateTask(task);
                  // this.loadTasks()
                })
                .margin({ right: 10 })
                .alignSelf(ItemAlign.Start) // 确保复选框顶部对齐

              Column() {
                Text(task.title)
                  .fontSize(18)
                  .fontColor(task.isCompleted ? '#888888' : '#000000')
                  .fontWeight(FontWeight.Bold)
                  .decoration({ type: task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                    // .fontColor(this.tasks[index].isCompleted ? '#888888' : '#000000')
                    // .decoration({ type: this.tasks[index].isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .width('85%')
                  .alignSelf(ItemAlign.Start)

                Row() {
                  if (task.projectId) {
                    this.ProjectLabel(task.projectId)

                  }

                  if (task.contextId) {
                    this.ContextLabel(task.contextId)

                  }

                  if (task.dueDate) {

                    Text(formatDateToChinese(task.dueDate, false))
                      .fontSize(16)
                      .fontColor(overDue(task.dueDate) ? '#FF0000' : '#888888')
                      .margin({ top: 5 }) // 为日期添加一些顶部边距
                  }


                }

              }
              .alignItems(HorizontalAlign.Start) // 确保文本左对齐
            }
            .width('100%')
            .padding(10)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .margin({ bottom: 10 })
            .alignItems(VerticalAlign.Top) // 确保Row内容顶部对齐
          }
          .swipeAction({ end: this.itemEnd(task) })
        }, task => task.id.toString())
      }
      .width('100%')

      Divider()
      .strokeWidth(0.5)
      .width('90%')
      .margin({top:10, bottom:10})


      // 添加一个按钮来控制已完成任务的显示/隐藏
      Button({ type: ButtonType.Normal, stateEffect: true }){
        Text(this.showCompletedTasks ? '显示已完成任务' : '隐藏已完成任务')
          .fontSize(16)
          .fontColor(this.showCompletedTasks ? Color.White : Color.Gray)
          .padding(5)
      }
      .height(30)
      .backgroundColor(this.showCompletedTasks ? '#ff343434' : '#ff343434')
      .borderRadius(5)
      .align(Alignment.Start)
      .alignSelf(ItemAlign.Start)
        .onClick(() => {
          this.showCompletedTasks = !this.showCompletedTasks;
        })
        .margin({ bottom: 10 })

      if(this.showCompletedTasks) {
        List() {
          ForEach(this.tasks
            .filter(task => task.isCompleted)
             .sort((a, b) => new Date(b.modifyTime).getTime() - new Date(a.modifyTime).getTime()),
            (task: TaskModel, index: number) => {
            ListItem() {
              Row() {
                Toggle({ type: ToggleType.Checkbox, isOn: task.isCompleted })
                  .onChange((isOn: boolean) => {
                    task.isCompleted = isOn;
                    this.gtdController.updateTask(task);
                    // this.loadTasks()
                  })
                  .margin({ right: 10 })
                  .alignSelf(ItemAlign.Start) // 确保复选框顶部对齐

                Column() {
                  Text(task.title)
                    .fontSize(18)
                    .fontColor(task.isCompleted ? '#888888' : '#000000')
                    .decoration({ type: task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                      // .fontColor(this.tasks[index].isCompleted ? '#888888' : '#000000')
                      // .decoration({ type: this.tasks[index].isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .width('85%')
                    .alignSelf(ItemAlign.Start)

                  Row() {
                    if (task.projectId) {
                      this.ProjectLabel(task.projectId)

                    }

                    if (task.contextId) {
                      this.ContextLabel(task.contextId)

                    }

                    if (task.dueDate) {

                      Text(formatDateToChinese(task.dueDate, false))
                        .fontSize(16)
                        .fontColor(overDue(task.dueDate) ? '#FF0000' : '#888888')
                        .margin({ top: 5 }) // 为日期添加一些顶部边距
                    }


                  }

                }
                .alignItems(HorizontalAlign.Start) // 确保文本左对齐
              }
              .width('100%')
              .padding(10)
              .borderRadius(8)
              .backgroundColor(Color.White)
              .margin({ bottom: 10 })
              .alignItems(VerticalAlign.Top) // 确保Row内容顶部对齐
            }
            .swipeAction({ end: this.itemEnd(task) })
          }, task => task.id.toString())
        }
        .width('100%')
      }
    }

  }
}
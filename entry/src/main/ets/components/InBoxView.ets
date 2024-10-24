import hilog from '@ohos.hilog';
import { ContextLabel, ProjectLabel, TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { formatDateToChinese, overDue } from '../common/utils';
import { ContextModel, ProjectModel, TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct InboxView {
  @Link tasks: TaskModel[];
  @State projects: ProjectModel[]|null = null;
  @Consume gtdController: GTDController;
  @Consume currentEditingTask: TaskModel;
  @Consume isPopupVisible: boolean;
  @State showCompletedTasks: boolean = false


  aboutToAppear(){
  }


  async loadTasks() {
    try {
      this.tasks = await this.gtdController.getAllTasks();
      hilog.debug(0x001,'tasksload',`tasksload:  ${JSON.stringify(this.tasks)}`)


    } catch (error) {
      console.error('Failed to load tasks:', error);
    }
    this.gtdController.initializeCache()
  }



  @Builder ProjectMenuBuilder() {
    Menu() {

      MenuItem({ content: '无项目' })
        .onClick(async () => {
          // this.selectedProject = { id: -1, name : '' }
          this.currentEditingTask.projectId = -1
          await this.gtdController.updateTask(this.currentEditingTask)
          // 这里可以添加清除选择后的逻辑
        })

      // ForEach(Object.values(this.gtdController.projectCache), (project: ProjectModel) => {
      ForEach(Object.values(this.gtdController.projectCache).sort((a, b) => a.name.localeCompare(b.name)), (project: ProjectModel) => {
        MenuItem({ content: project.name })
          .onClick(async () => {
            // this.selectedProject = project
            this.currentEditingTask.projectId = project.id
            await this.gtdController.updateTask(this.currentEditingTask)
            // 这里可以添加选择 context 后的逻辑，比如更新任务的 context
          })

      })
    }
  }
  @Builder contextMenuBuilder() {
    Menu() {
      MenuItem({ content: '无场景' })
        .onClick(async () => {
          // this.selectedContext = { id: -1, name : '' }
          this.currentEditingTask.contextId = -1
          await this.gtdController.updateTask(this.currentEditingTask)
          // 这里可以添加清除选择后的逻辑
        })

      ForEach(Object.values(this.gtdController.contextCache), (context: ContextModel) => {
        MenuItem({ content: context.name })
          .onClick(async () => {
            // this.selectedContext = context
            this.currentEditingTask.contextId = context.id
            await this.gtdController.updateTask(this.currentEditingTask)
            // 这里可以添加选择 context 后的逻辑，比如更新任务的 context
          })

      })
    }
  }
  @Builder itemEnd(record: TaskModel) {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('项目')
          .fontColor(Color.White)
          .width(40)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .onClick(() => {
        this.currentEditingTask = record;
      })
      .margin({right:1})
      .bindMenu(this.ProjectMenuBuilder)

      Button({ type: ButtonType.Normal }) {
        Text('场景')
          .fontColor(Color.White)
          .width(40)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .onClick(() => {
        this.currentEditingTask = record;
      })
      .margin({right:1})
      .bindMenu(this.contextMenuBuilder)


      Button({ type: ButtonType.Normal }) {
        Text('EDIT')
          .fontColor(Color.White)
          .width(40)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .onClick(() => {
        this.currentEditingTask = record;
        this.isPopupVisible = true;
        // this.loadTasks()
      })
      .margin({right:1})
      // 侧滑后尾端出现的组件
      Button({ type: ButtonType.Normal }) {
        Text('DEL')
          .fontColor(Color.White)
          .width(40)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.deleteButtonColor)
      .onClick(async () => {
        // this.controller.deleteMoodRecord(record.id)
        await this.gtdController.deleteTask(record.id)
        // this.loadTasks()

      })

    }
  }

  @Builder itemStart(record: TaskModel) {
    Row() {

      Button({ type: ButtonType.Normal }) {
        Text(record.flagged ? '-🌟' : '🌟' )
          .fontColor(Color.White)
          .width(45)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.deleteButtonColor)
      .onClick(async () => {
        // this.controller.deleteMoodRecord(record.id)
        this.currentEditingTask = record;
        this.currentEditingTask.flagged = !this.currentEditingTask.flagged
        await this.gtdController.updateTask(this.currentEditingTask)

      })
      Button({ type: ButtonType.Normal }) {
        Text('0d')
          .fontColor(Color.White)
          .width(45)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .margin({right:1})
      .onClick(() => {
        this.currentEditingTask = record;
        const today = new Date()
        this.currentEditingTask.dueDate = today
        this.currentEditingTask.dueDate.setDate(today.getDate() + 0)
        this.gtdController.updateTask(this.currentEditingTask)
      })

      Button({ type: ButtonType.Normal }) {
        Text('+1d')
          .fontColor(Color.White)
          .width(45)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .margin({right:1})

      .onClick(() => {
        this.currentEditingTask = record;
        const today = new Date()
        this.currentEditingTask.dueDate = today
        this.currentEditingTask.dueDate.setDate(today.getDate() + 1)
        this.gtdController.updateTask(this.currentEditingTask)
      })
      Button({ type: ButtonType.Normal }) {
        Text('+7d')
          .fontColor(Color.White)
          .width(45)
          .height('80%')
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .margin({right:1})

      .onClick(() => {
        this.currentEditingTask = record;
        const today = new Date()
        this.currentEditingTask.dueDate = today
        this.currentEditingTask.dueDate.setDate(today.getDate() + 7)
        this.gtdController.updateTask(this.currentEditingTask)
      })



    }
  }







  build() {
    Column() {
      List() {
        ForEach(this.tasks
          .filter(task => !task.isCompleted && (task.projectId == null || task.projectId == undefined || task.projectId == -1)),
          (task: TaskModel, index: number) => {
            ListItem() {
              TaskItem(task, this.gtdController, () => this.loadTasks())
            }
            .swipeAction({ end: this.itemEnd(task), start: this.itemStart(task) })
          }
        )
      }
      .width('100%')

      // Divider()
      //   .strokeWidth(0.5)
      //   .width('90%')
      //   .margin({top:10, bottom:10})


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
            .filter(task => task.isCompleted && !!task.projectId)
            .sort((a, b) => new Date(b.modifyTime).getTime() - new Date(a.modifyTime).getTime()),
            (task: TaskModel, index: number) => {
              ListItem() {
                TaskItem(task, this.gtdController, () => this.loadTasks())
              }
              .swipeAction({ end: this.itemEnd(task), start: this.itemStart(task) })
            })
        }
        .width('100%')
      }
    }

  }
}



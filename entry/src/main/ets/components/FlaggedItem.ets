import hilog from '@ohos.hilog';
import { ContextLabel, ProjectLabel, TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { formatDateToChinese, overDue } from '../common/utils';
import { ProjectModel, TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export struct FlaggedItem {
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
        this.loadTasks()
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
        await this.gtdController.deleteTask(record.id)
        this.loadTasks()

      })

    }
  }






  build() {
    Column() {
      List() {
        ForEach(this.tasks
          .filter(task => !task.isCompleted && task.flagged),
          (task: TaskModel, index: number) => {
            ListItem() {
              TaskItem(task, this.gtdController, () => this.loadTasks())
            }
            .swipeAction({ end: this.itemEnd(task) })
          }
          // , (task: TaskModel ,index:number) => {return index + '_' +  task.isCompleted.toString();}
        )
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
            .filter(task => task.isCompleted && task.flagged)
            .sort((a, b) => new Date(b.modifyTime).getTime() - new Date(a.modifyTime).getTime()),
            (task: TaskModel, index: number) => {
              ListItem() {
                TaskItem(task, this.gtdController, () => this.loadTasks())
              }
              .swipeAction({ end: this.itemEnd(task) })
            })
        }
        .width('100%')
      }
    }

  }
}



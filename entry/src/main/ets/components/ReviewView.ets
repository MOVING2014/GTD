import hilog from '@ohos.hilog';
import { TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { formatDate, formatDateTime } from '../common/utils';
import { TaskModel, ProjectModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';

@Component
export  struct ReviewView {
  @Consume gtdController: GTDController;
  @Link  projects: ProjectModel[];
  @Consume taskUpdateTrigger: number;
  @Consume isPopupVisible: boolean;
  @Consume currentEditingTask: TaskModel;

  @State private currentIndex: number = 0;

  @State isEditingProject: boolean = false;
  @State editingProject: ProjectModel | undefined = undefined;
  @State reviewingProject: ProjectModel = undefined;

  @State reviewComplete: boolean = false;



  async aboutToAppear(){
    if(this.projects) {
      this.reviewingProject = this.projects[0]
      this.reviewComplete = this.isReviewComplete();
    }
    hilog.debug(0x001,'ProjectView',`project for taskids: ${this.projects}`)
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
        // hilog.debug(0x009,'TaskItem',`TaskItem load tasks ${JSON.stringify(this.tasks[1])}`)

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




  isReviewComplete(): boolean {
    const today = new Date();
    // sixDaysLater.setDate(sixDaysLater.getDate() + 6);

    return this.projects.every(project => {
      if (!project.reviewedDate) return false;
      const reviewDate = new Date(project.reviewedDate);
      reviewDate.setDate(reviewDate.getDate() + 6)
      hilog.debug(0x001,'ReviewView', `revieday/today: ${reviewDate.toString()}, ${today.toString()}, ${reviewDate.getTime() >= today.getTime()}`)
      return reviewDate.getTime() >= today.getTime();
    });
  }


  @Builder
  ProjectCard() {
    Column() {
      Row() {
        Text(this.reviewingProject.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ right: 10 })
        Blank()
        Text(this.reviewingProject.reviewedDate ? `上次回顾:${formatDateTime(this.reviewingProject.reviewedDate)}` : '未回顾')
          .fontSize(16)

      }.width('100%')
      .alignItems(VerticalAlign.Center)
      .align(Alignment.Start)

      Text(this.reviewingProject.description || 'No description')
        .fontSize(16)
        .margin({ bottom: 10 })
      .width('100%')
      .textAlign(TextAlign.Start)



      if (this.reviewingProject.taskIds) {
        Divider()
          .strokeWidth(Constants.dividerWidth)
          .width('95%')
          .color(Constants.dividerColor)
          .margin({bottom:10})


        List() {
          ForEach(this.reviewingProject.taskIds.filter(
            taskID => !this.gtdController.taskCache[taskID].isCompleted
          ), (taskId: number) => {
            ListItem() {
              TaskItem(this.gtdController.taskCache[taskId],
                this.gtdController,
                async () => {
                  this.taskUpdateTrigger++
                })
            }
            .swipeAction({ end: this.itemEnd(this.gtdController.taskCache[taskId]),
              start: this.itemStart(this.gtdController.taskCache[taskId])
            })
          },   taskId => `${taskId}-${this.gtdController.taskCache[taskId].isCompleted}-${this.taskUpdateTrigger}`
          )
        }
        .width('100%')
      }

    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 10, color: 0x3f000000, offsetX: 2, offsetY: 2 })
    .layoutWeight(1)
  }

  updateReviewingProject() {
    // this.reviewingProject = JSON.parse(JSON.stringify(this.projects[this.currentIndex]));
    this.reviewingProject = this.projects[this.currentIndex]
    this.taskUpdateTrigger++;
    this.reviewComplete = this.isReviewComplete();
  }

  updateIndex(direction: 'next' | 'previous') {
    if (this.projects.length === 0) return;  // 如果没有项目，直接返回
    if (direction === 'next') {
      this.currentIndex = (this.currentIndex + 1) % this.projects.length;
    } else {
      this.currentIndex = (this.currentIndex - 1 + this.projects.length) % this.projects.length;
    }
    this.updateReviewingProject();
  }


  build() {
    Column(){
      if(this.projects.length > 0){
        if (this.reviewComplete) {
          Text("所有项目回顾已完成！")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
            .fontColor(Constants.reviewCompleted)
        }

        this.ProjectCard()
        Row() {
          Button('上一个')
            .backgroundColor(Color.Gray)
            .onClick(() => {
              hilog.debug(0x001,'ReviewView', `reviewing projects: ${JSON.stringify(this.reviewingProject)}`)
              this.updateIndex('previous');
            })
            .margin({ right: 10 })

          Button('标记为已回顾')
            .backgroundColor(Color.Gray)
            .onClick(async () => {
              const reviewDate = new Date()
              this.reviewingProject.reviewedDate = reviewDate
              await this.gtdController.updateProject(this.reviewingProject)
              hilog.debug(0x001,'ReviewView', `reviewing projects:reviewDate ${reviewDate}`)
              hilog.debug(0x001,'ReviewView', `reviewing current index: ${this.currentIndex}`)
              this.updateIndex('next');

            })
            .margin({ right: 10 })
            .enabled(!this.reviewComplete)

          Button('下一个')
            .backgroundColor(Color.Gray)
            .onClick(() => {
              hilog.debug(0x001,'ReviewView', `reviewing projects: ${JSON.stringify(this.reviewingProject)}`)
              this.updateIndex('next');


            })
        }
        .margin({ top: 20 })
        Text(`${this.currentIndex + 1} / ${this.projects.length}`)
          .fontSize(16)
          .margin({ top: 10 })

        } else {
          Text('No projects available')
            .fontSize(16)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    .margin({top:20})


  }
}
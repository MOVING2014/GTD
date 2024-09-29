// import { TaskData, ProjectData } from './DataTypes'
import hilog from '@ohos.hilog';
import { TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { TaskModel, ProjectModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';



@Component
export  struct ProjectView {
  @Consume gtdController: GTDController;
  // @Link tasks: TaskModel[];
  @Link  projects: ProjectModel[];
  @State loadingProjects: Set<number> = new Set()
  @State taskUpdateTrigger: number = 0;
  @State isLoading: boolean  = true;

  // @Consume isPopupVisible: boolean;
  // @State showCompletedTasks: boolean = false
  async aboutToAppear(){
    this.isLoading = true
    await this.loadProjects()
    hilog.debug(0x001,'ProjectView',`project for taskids: ${this.projects}`)
  }

  async loadProjects() {
    this.isLoading = true
    try {
      this.projects = await this.gtdController.getAllProjects();
      await this.gtdController.initializeCache();
      this.isLoading = false
    } catch (error) {
      console.error('Failed to load projects:', error);
    }
    // await this.gtdController.initializeCache()

  }




  build() {
    if(!this.isLoading) {

      List() {
        ForEach(this.projects, (project: ProjectModel) => {
          ListItem() {
            this.ProjectItem(project)
          }
        }
          , project => `${JSON.stringify(project)}`
        )
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder ProjectItem(project: ProjectModel) {
    Column() {
      Row() {
        Text(project.isExpended ? '📂' : '📁')  // 文件夹emoji
          .fontSize(24)
          .margin({ right: 10 })
        Text(project.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Gray)
        Blank()

      }
      .width('100%')
      // .height(50)
      .backgroundColor(Color.White)
      .padding({ left: 0, right: 16 })
      .onClick(async () => {
        project.isExpended = !project.isExpended
        await this.gtdController.updateProject(project)
        await this.loadProjects()
        hilog.debug(0x001, 'ProjectView:ProjectItem', `project： ${JSON.stringify(this.projects)}`)
        this.taskUpdateTrigger++;
        hilog.debug(0x001, 'ProjectView:ProjectItem', `taskUpdateTrigger： ${JSON.stringify(this.taskUpdateTrigger)}`)

      })

      if(project.description) {
        Row() {
          Text(project.description)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.Grey)
            .margin({left:40, bottom:10})
          Blank()

        } .width('100%')
      }

      if (project.isExpended) {
        if (project.taskIds) {
          List() {
            ForEach(project.taskIds.filter(
              taskID => !this.gtdController.taskCache[taskID].isCompleted
            ), (taskId: number) => {
              ListItem() {
                TaskItem(this.gtdController.taskCache[taskId],
                  this.gtdController,
                  async () => {
                    await this.loadProjects()
                    this.taskUpdateTrigger++
                    hilog.debug(0x001, 'ProjectView:ProjectItem', `taskUpdateTrigger:${this.taskUpdateTrigger}`)
                    hilog.debug(0x001, 'ProjectView:ProjectItem', `taskkey: ${taskId}-${this.gtdController.taskCache[taskId].isCompleted}-${this.taskUpdateTrigger}`)

                  })
              }
            },   taskId => `${taskId}-${this.gtdController.taskCache[taskId].isCompleted}-${this.taskUpdateTrigger}`
            )
          }
          .width('100%')
        }
      }
    }
  }

}
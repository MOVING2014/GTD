// import { TaskData, ProjectData } from './DataTypes'
import hilog from '@ohos.hilog';
import { TaskItem } from '../common/CommonBuilders';
import { TaskModel, ProjectModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';



@Component
export  struct ProjectView {
  @Consume gtdController: GTDController;
  // @Link tasks: TaskModel[];
  @State projects: ProjectModel[] = [];
  @State loadingProjects: Set<number> = new Set()
  @State taskUpdateTrigger: number = 0;

  // @Consume isPopupVisible: boolean;
  // @State showCompletedTasks: boolean = false
  aboutToAppear(){
    this.loadProjects()
  }

  async loadProjects() {
    try {
      this.projects = await this.gtdController.getAllProjects();
      this.gtdController.initializeCache();

    } catch (error) {
      console.error('Failed to load projects:', error);
    }
    await this.gtdController.initializeCache()

  }




  build() {
    List() {
      ForEach(this.projects, (project: ProjectModel) => {
        ListItem() {
          this.ProjectItem(project)
        }
      })
    }
    .width('100%')
    .height('100%')
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
      .height(50)
      .backgroundColor(Color.White)
      .padding({ left: 0, right: 16 })
      .onClick(() => {
        project.isExpended = !project.isExpended
        this.projects = [...this.projects]
      })

      if (project.isExpended) {
        if (project.taskIds) {
          List() {
            ForEach(project.taskIds.filter(
              taskID => !this.gtdController.taskCache[taskID].isCompleted
            ), (taskId: number) => {
              ListItem() {
                TaskItem(this.gtdController.taskCache[taskId],
                  this.gtdController,
                  () => {
                    this.loadProjects()
                    this.taskUpdateTrigger++

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
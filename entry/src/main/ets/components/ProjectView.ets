// import { TaskData, ProjectData } from './DataTypes'
import hilog from '@ohos.hilog';
import { TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { TaskModel, ProjectModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import { NewProjectForm } from './AddProject';



@Component
export  struct ProjectView {
  @Consume gtdController: GTDController;
  // @Link tasks: TaskModel[];
  @Link  projects: ProjectModel[];
  @State loadingProjects: Set<number> = new Set()
  @Consume taskUpdateTrigger: number;
  @Consume isPopupVisible: boolean;
  @State showCompletedTasks: boolean = false
  @Consume currentEditingTask: TaskModel;

  @State isEditingProject: boolean = false;
  @State editingProject: ProjectModel | undefined = undefined;



  async aboutToAppear(){
    await this.loadProjects()
    hilog.debug(0x001,'ProjectView',`project for taskids: ${this.projects}`)
  }

  async loadProjects() {
    try {
      this.projects = await this.gtdController.getAllProjects();
      await this.gtdController.initializeCache();
    } catch (error) {
      console.error('Failed to load projects:', error);
    }
    // await this.gtdController.initializeCache()

  }

  async updateNewProject() {

      try {
        const createdProject = await this.gtdController.updateProject(this.editingProject);
        this.projects = await this.gtdController.getAllProjects()

      } catch (error) {
        console.error('Failed to create project:', error);
        // 可以在这里添加错误处理，比如显示一个提示
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


  @Builder projectEnd(project: ProjectModel) {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('EDIT')
          .fontColor(Color.White)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
      }
      .backgroundColor(Constants.editButtonColor)
      .onClick(async  () => {
        this.isEditingProject = true;
        this.editingProject = project
        this.taskUpdateTrigger ++;
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
        await this.gtdController.deleteProject(project.id)
        this.taskUpdateTrigger ++;

      })

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
              .swipeAction({ end: this.itemEnd(this.gtdController.taskCache[taskId]) })
            },   taskId => `${taskId}-${this.gtdController.taskCache[taskId].isCompleted}-${this.taskUpdateTrigger}`
            )
          }
          .width('100%')
        }
      }
    }
  }


  build() {

      List() {
        ForEach(this.projects, (project: ProjectModel) => {
          ListItem() {
            Column() {

              this.ProjectItem(project)
              if (this.isEditingProject && project.id === this.editingProject.id) {
                NewProjectForm({
                  newProjectName: this.editingProject.name,
                  newProjectDescription: this.editingProject.description,
                  onNewProjectNameChange: (value: string) => {
                    this.editingProject.name = value;
                  },
                  onNewProjectDescriptionChange: (value: string) => {
                    this.editingProject.description = value;
                  },
                  onCancel: () => {
                    this.isEditingProject = false;
                  },
                  onSubmit: () => {
                    this.updateNewProject();
                    this.isEditingProject = false;
                  }
                })

              }

            }
          }
          .swipeAction({ end: this.projectEnd(project) })

        }
          , project => `${JSON.stringify(project)}—${this.taskUpdateTrigger}`
        )
      }
      .width('100%')
      .height('100%')

  }




}
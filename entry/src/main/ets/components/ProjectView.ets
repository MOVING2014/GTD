// import { TaskData, ProjectData } from './DataTypes'
import hilog from '@ohos.hilog';
import { describe } from '@ohos/hypium';
import { TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { TaskModel, ProjectModel, ContextModel } from '../models/IModels';
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

      // 对每个项目的任务进行排序
      this.projects.forEach(project => {
        if (project.taskIds) {
          project.taskIds.sort((a, b) => {
            const dateA = this.gtdController.taskCache[a].dueDate ? new Date(this.gtdController.taskCache[a].dueDate).getTime() : Infinity;
            const dateB = this.gtdController.taskCache[b].dueDate ? new Date(this.gtdController.taskCache[b].dueDate).getTime() : Infinity;
            return dateA - dateB;
          });
        }
      });
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

        Text(project.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Gray)
        Blank()
        Text(project.isExpended ? '📂' : '📁')  // 文件夹emoji
          .fontSize(16)
          .margin({ right: 10 })

      }
      .width('100%')
      // .height(50)
      .backgroundColor(Color.White)
      .padding({ left: 8, right: 16 })
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
            .margin({ bottom:10})
          Blank()

        } .width('100%')
        .padding({ left: 8, right: 16 })
        .onClick(async () => {
          project.isExpended = !project.isExpended
          await this.gtdController.updateProject(project)
          await this.loadProjects()
          hilog.debug(0x001, 'ProjectView:ProjectItem', `project： ${JSON.stringify(this.projects)}`)
          this.taskUpdateTrigger++;
          hilog.debug(0x001, 'ProjectView:ProjectItem', `taskUpdateTrigger： ${JSON.stringify(this.taskUpdateTrigger)}`)

        })

      }

      if (project.isExpended) {
        if (project.taskIds) {
          if(project.isExpended){
            Divider()
              .strokeWidth(Constants.dividerWidth)
              .width('95%')
              .color(Constants.dividerColor)
              .margin({bottom:Constants.taskMarginBottom})
          }
          List() {
            ForEach(project.taskIds.filter(
              taskID => !this.gtdController.taskCache[taskID].isCompleted
            )
              .sort((a, b) => {
                const dateA = this.gtdController.taskCache[a].dueDate ? new Date(this.gtdController.taskCache[a].dueDate).getTime() : Infinity;
                const dateB = this.gtdController.taskCache[b].dueDate ? new Date(this.gtdController.taskCache[b].dueDate).getTime() : Infinity;
                return dateA - dateB;
              })

            , (taskId: number) => {
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
              .swipeAction({ end: this.itemEnd(this.gtdController.taskCache[taskId]),
                start: this.itemStart(this.gtdController.taskCache[taskId])
              })
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
                  title: this.editingProject.name,
                  description: this.editingProject.description,
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
      .layoutWeight(1)
      // .height('100%')

  }




}
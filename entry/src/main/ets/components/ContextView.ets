// import { TaskData, ProjectData } from './DataTypes'
import hilog from '@ohos.hilog';
import { describe } from '@ohos/hypium';
import { TaskItem } from '../common/CommonBuilders';
import { Constants } from '../common/Constants';
import { TaskModel, ProjectModel, ContextModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import { NewContextForm } from './AddContext';
import { NewProjectForm } from './AddProject';



@Component
export  struct ContextView {
  @Consume gtdController: GTDController;
  // @Link tasks: TaskModel[];
  @Link  tasks: TaskModel[];
  @Link  contexts: ContextModel[];
  @Consume taskUpdateTrigger: number;
  @Consume isPopupVisible: boolean;
  @State showCompletedTasks: boolean = false
  @Consume currentEditingTask: TaskModel;

  @State isEditingContext: boolean = false;
  @State editingContext: ContextModel | undefined = undefined;



  async aboutToAppear(){
    await this.loadContexts()
    hilog.debug(0x001,'ContextView',`Context for taskids: ${this.contexts}`)
  }

  async loadContexts() {
    try {
      this.contexts = await this.gtdController.getAllContexts();
      await this.gtdController.initializeCache();
    } catch (error) {
      console.error('Failed to load contexts:', error);
    }

  }

  async updateNewContext() {

    try {
      const createdContext = await this.gtdController.updateContext(this.editingContext);
      this.contexts = await this.gtdController.getAllContexts()

    } catch (error) {
      console.error('Failed to create project:', error);
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


  @Builder contextEnd(context: ContextModel) {
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
        this.isEditingContext = true;
        this.editingContext = context
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
        await this.gtdController.deleteContext(context.id)
        this.taskUpdateTrigger ++;

      })

    }
  }



  @Builder contextItem(context: ContextModel) {
    Column() {
      Row() {
        Text(context.isExpended ? '📂' : '📁')  // 文件夹emoji
          .fontSize(24)
          .margin({ right: 10 })
        Text(context.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Gray)
        Blank()

      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ left: 0, right: 16 })
      .onClick(async () => {
        context.isExpended = !context.isExpended
        await this.gtdController.updateContext(context)
        await this.loadContexts()
        hilog.debug(0x001, 'ContextView:ContextItem', `Context： ${JSON.stringify(this.contexts)}`)
        this.taskUpdateTrigger++;
        hilog.debug(0x001, 'ContextView:ContextItem', `taskUpdateTrigger： ${JSON.stringify(this.taskUpdateTrigger)}`)

      })

      if(context.description) {
        Row() {
          Text(context.description)
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.Grey)
            .margin({left:40, bottom:10})
          Blank()

        } .width('100%')
      }

      if (context.isExpended) {
        if (this.gtdController.contextIDTaskIDMap2Array[context.id]) {
          List() {
            ForEach(this.gtdController.contextIDTaskIDMap2Array[context.id].filter(
              taskID => !this.gtdController.taskCache[taskID].isCompleted
            ), (taskId: number) => {
              ListItem() {
                TaskItem(this.gtdController.taskCache[taskId],
                  this.gtdController,
                  async () => {
                    await this.loadContexts()
                    this.taskUpdateTrigger++
                    hilog.debug(0x001, 'ContextView', `taskUpdateTrigger:${this.taskUpdateTrigger}`)
                    hilog.debug(0x001, 'ContextView', `taskkey: ${taskId}-${this.gtdController.taskCache[taskId].isCompleted}-${this.taskUpdateTrigger}`)

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
      ForEach(this.contexts, (context: ContextModel) => {
        ListItem() {
          Column() {

            this.contextItem(context)
            if (this.isEditingContext && context.id === this.editingContext.id) {
              NewContextForm({
                newContextName: this.editingContext.name,
                newContextDescription: this.editingContext.description,
                title: this.editingContext.name,
                description: this.editingContext.description,
                onNewContextNameChange: (value: string) => {
                  this.editingContext.name = value;
                },
                onNewContextDescriptionChange: (value: string) => {
                  this.editingContext.description = value;
                },
                onCancel: () => {
                  this.isEditingContext = false;
                },
                onSubmit: () => {
                  this.updateNewContext();
                  this.isEditingContext = false;
                }
              })

            }

          }
        }
        .swipeAction({ end: this.contextEnd(context) })

      }
        , context => `${JSON.stringify(context)}—${this.taskUpdateTrigger}`
      )
    }
    .width('100%')
    .height('100%')

  }
}
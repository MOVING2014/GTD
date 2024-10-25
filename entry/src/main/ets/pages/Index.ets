import { ContextModel, ProjectModel, TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import {  TaskList } from '../components/TaskItem'
import { AddTaskComponent } from '../components/AddTask';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import inputMethod from '@ohos.inputMethod';
import { DatabaseGTDDataSource } from '../data/DatabaseGTDDataSource';
import window from '@ohos.window';
import display from '@ohos.display';
import { FlaggedItem } from '../components/FlaggedItem';
import { MockGTDDataSource } from '../data/MockGTDDataSource';
import { ProjectView } from '../components/ProjectView';
import { WeekView } from '../components/Calendar';
import { InboxView } from '../components/InBoxView';
import { isSameDay, stringToDate } from '../common/utils';
import { NewProjectForm } from '../components/AddProject';
import { ContextView } from '../components/ContextView';
import { NewContextForm } from '../components/AddContext';
import { ReviewView } from '../components/ReviewView';
import router from '@ohos.router';
import { Constants } from '../common/Constants';

@Entry
@Component
struct Index {
  // @Provide gtdController: GTDController = new GTDController(new MockGTDDataSource);
  @Provide gtdController: GTDController = new GTDController(new DatabaseGTDDataSource());
  @Provide currentEditingTask: TaskModel | {id:-1, name:'', createdDate:Date, isCompleted:boolean } = {id:-1, name:'', createdDate:new Date(0), isCompleted:false};
  @Provide isPopupVisible: boolean = false;
  @Provide taskUpdateTrigger: number = 0;

  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;
  @State tasks: TaskModel[] = [];
  @State projects: ProjectModel[] = [];
  @State contexts: ContextModel[] = [];

  @State popupTranslateY: number = 100;

  @State windowInstance: window.Window | null = null;

  @State StackHeight: number = 0;
  @State keyBoardHeight: number = 0;
  @State topMargin: number = 0;

  @State private isAddingProject: boolean = false;
  @State private isAddingContext: boolean = false;
  @State private newProjectName: string = '';
  @State private newProjectDescription: string = '';
  @State private newContextName: string = '';
  @State private newContextDescription: string = '';

  @State isLoading: boolean = true;
  @State selectedDateString: string = new Date().toString();

  @State filteredTasks: TaskModel[] = [];




  async aboutToAppear() {
    this.isLoading = true;
    this.gtdController.addObserver(()=>this.loadTasks())
    await this.loadTasks();
    this.isLoading = false;


    // 获取当前窗口
    window.getLastWindow(getContext(this), (err, data) => {
      if (err.code) {
        console.error('Failed to obtain the top window. Cause: ' + JSON.stringify(err));
        return;
      }
      const displayClass = display.getDefaultDisplaySync();
      const screenHeight = displayClass.height;
      let property = data.getWindowProperties();
      this.StackHeight = px2vp(property.windowRect.height)


      this.windowInstance = data;
      // 设置软键盘弹出模式

      if (this.windowInstance) {
        this.windowInstance.on('keyboardHeightChange', (height: number) => {
          this.keyBoardHeight = px2vp(height)
          this.StackHeight = px2vp(property.windowRect.height - height - 0)
          this.topMargin = this.keyBoardHeight === 0 ? 0: (this.keyBoardHeight - 55)
          //todo: 需要看一下55 是什么数字
          hilog.debug(0x002,'IndexPage',`componentElevationChanged:${this.StackHeight}`)
          hilog.debug(0x002,'IndexPage',`keyboardheight:${height}`)
        });
      }



    })
  }

  async loadTasks() {

    try {

      this.tasks = await this.gtdController.getAllTasks();
      hilog.debug(0x001,'tasksload',`tasksload:  ${JSON.stringify(this.tasks)}`)
      this.projects = await this.gtdController.getAllProjects()
      this.contexts = await this.gtdController.getAllContexts()
      await this.gtdController.initializeCache()



      this.filterTasks(stringToDate(this.selectedDateString));
      this.taskUpdateTrigger++

    } catch (error) {
      console.error('Failed to load tasks:', error);
    }


  }



  showPopup() {
    this.isPopupVisible = true;
    animateTo({ duration: 400, curve: Curve.EaseInOut }, () => {
      // this.popupOpacity = 1;
      this.popupTranslateY = 0;

    });

  }

  hidePopup() {
    animateTo({ duration: 100,
      onFinish: () => {
        this.isPopupVisible = false;
      }

    }, () => {
      this.popupTranslateY = 400;
    });
  }

  @Builder TabBuilder(title: string, index: number, emoji: string) {
    Column() {
      Text(emoji)
        .fontSize(24)
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  async createNewProject() {
    if (this.newProjectName.trim()) {
      try {
        const newProject: ProjectModel = {
          id: Date.now(), // 临时使用时间戳作为ID，实际应该由后端生成
          name: this.newProjectName.trim(),
          description: this.newProjectDescription.trim(),
          taskIds: [], // 新项目默认没有任务
          isExpended: false, // 新创建的项目默认不展开

        };
        const createdProject = await this.gtdController.createProject(newProject);
        this.projects = await this.gtdController.getAllProjects()

      } catch (error) {
        console.error('Failed to create project:', error);
        // 可以在这里添加错误处理，比如显示一个提示
      }
    }
  }

  async createNewContext() {
    if (this.newContextName.trim()) {
      try {
        const newContext: ContextModel = {
          id: Date.now(), // 临时使用时间戳作为ID，实际应该由后端生成
          name: this.newContextName.trim(),
          description: this.newContextDescription.trim(),
          isExpended: false, // 新创建的项目默认不展开
        };
        const createdContext = await this.gtdController.createContext(newContext);
        this.contexts = await this.gtdController.getAllContexts()

      } catch (error) {
        console.error('Failed to create project:', error);
        // 可以在这里添加错误处理，比如显示一个提示
      }
    }
  }

  handleDateSelect(date: Date |'') {
    if(date === ''){
      this.filteredTasks = this.tasks
    }else {
      this.selectedDateString = date.toString();
      this.filterTasks(date);
    }

    // 这里可以添加筛选任务的逻辑
    // hilog.debug(0x001, 'TaskList', `Selected date: ${date.toDateString()}`);
  }

  // private filterTasks(selectedDate: Date) {
  //   // 确保选中的日期只包含年月日信息，不包含时分秒
  //   const startOfDay = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
  //   const endOfDay = new Date(startOfDay);
  //   endOfDay.setDate(endOfDay.getDate() + 1);
  //
  //   this.filteredTasks = this.tasks.filter(task => {
  //     const taskDate = new Date(task.dueDate);
  //     return isSameDay(taskDate, selectedDate)
  //   });
  //
  // }


  private filterTasks(selectedDate: Date) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const startOfSelectedDay = new Date(selectedDate);
    startOfSelectedDay.setHours(0, 0, 0, 0);

    const endOfSelectedDay = new Date(startOfSelectedDay);
    endOfSelectedDay.setHours(23, 59, 59, 999);

    const futureDateThreshold = new Date(today);
    futureDateThreshold.setDate(today.getDate() + 5);
    futureDateThreshold.setHours(0, 0, 0, 0);


    this.filteredTasks = this.tasks.filter(task => {
      if (!task.dueDate) return false;
      const taskDate = new Date(task.dueDate);

      if (endOfSelectedDay.getTime() < today.getTime()) {
        // 对于昨天及之前的日期
        return taskDate.getTime() <= endOfSelectedDay.getTime();
      } else if (startOfSelectedDay.getTime() >= futureDateThreshold.getTime()) {
        // 对于今天之后的第5天及以后的日期
        return taskDate.getTime() >= futureDateThreshold.getTime();
      } else {
        // 对于今天及将来的日期
        return isSameDay(taskDate, selectedDate);
      }
    });
  }



  build() {

    if(this.isLoading) {
      Column() {
        LoadingProgress()
          .color(Color.Green)
          .width(50)
          .height(50)
        Text('加载中...')
          .fontSize(16)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }else  if(!this.isLoading) {


      Stack({ alignContent: Alignment.BottomEnd }) {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {

          TabContent() {
            // 收集
            Column() {
              Row(){
                Blank()
                Button('配置')
                  .fontSize(Constants.fontSizeMedium)
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(Constants.textColorSecondary)
                  .height(24)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Settings'
                    });
                  })
                  .margin({right:5})
              }
              .width('100%')
              .height(40)
              .borderWidth({
                bottom:1
              })
              .borderColor(Constants.dividerColor2)
              .borderStyle(BorderStyle.Solid)


              Text("收集")
                .fontSize(32)
                .fontColor(Constants.titleColorInbox)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ top: 8, bottom: 8, left: 16 })



              InboxView({
                tasks: $tasks
              })


            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行

          }
          .tabBar(this.TabBuilder("收集箱", 0, "📥"))

          TabContent() {
            Column() {

              Row(){
                Blank()
                Button('配置')
                  .fontSize(Constants.fontSizeMedium)
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(Constants.textColorSecondary)
                  .height(24)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Settings'
                    });
                  })
                  .margin({right:5})
              }
              .width('100%')
              .height(40)
              .borderWidth({
                bottom:1
              })
              .borderColor(Constants.dividerColor2)
              .borderStyle(BorderStyle.Solid)


              Text("预测")
                .fontSize(32)
                .fontColor(Constants.titleColorPrediction)
                .fontWeight(FontWeight.Medium)
                .padding({ top: 8, bottom: 8, left: 16 })

              WeekView({
                tasks: $tasks,
                onDateSelect: this.handleDateSelect.bind(this) })

              TaskList({
                tasks: $filteredTasks
              })


            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行


          }
          .tabBar(this.TabBuilder("预测", 1, "📅"))


          TabContent() {
            // 项目页面内容
            Column() {
              Row(){
                Blank()
                Button({ type: ButtonType.Capsule, stateEffect: true }) {
                  Text('++')
                    // .width(24)
                    // .height(24)
                }
                .width(40)
                .height(24)
                .margin({ right: 16 })
                .onClick(() => {
                  this.isAddingProject = true
                })

                Button('配置')
                  .fontSize(Constants.fontSizeMedium)
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(Constants.textColorSecondary)
                  .height(24)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Settings'
                    });
                  })
                  .margin({right:5})
              }
              .width('100%')
              .height(40)
              .borderWidth({
                bottom:1
              })
              .borderColor(Constants.dividerColor2)
              .borderStyle(BorderStyle.Solid)


              Text("项目")
                .fontSize(32)
                .fontColor(Constants.titleColorInbox)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ top: 8, bottom: 8, left: 16 })

              if (this.isAddingProject) {
                NewProjectForm({
                  newProjectName: this.newProjectName,
                  newProjectDescription: this.newProjectDescription,
                  title:'',
                  description:'',
                  onNewProjectNameChange: (value: string) => {
                    this.newProjectName = value;
                  },
                  onNewProjectDescriptionChange: (value: string) => {
                    this.newProjectDescription = value;
                  },
                  onCancel: () => {
                    this.isAddingProject = false;
                  },
                  onSubmit: () => {
                    this.createNewProject();
                    this.newProjectName = ''
                    this.newProjectDescription = ''
                    this.isAddingProject = false;
                  }
                })

              }

              if(this.projects) {
                ProjectView({
                  projects: $projects
                })
              }

            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行
          }
          .tabBar(this.TabBuilder("项目", 2, "📁"))

          TabContent() {
            // Context页面内容
            Column() {

              Row(){
                Blank()
                Button({ type: ButtonType.Capsule, stateEffect: true }) {
                  Text('++')

                }
                .width(40)
                .height(24)
                .margin({ right: 16 })
                .onClick(() => {
                  this.isAddingContext = true
                })

                Button('配置')
                  .fontSize(Constants.fontSizeMedium)
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(Constants.textColorSecondary)
                  .height(24)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Settings'
                    });
                  })
                  .margin({right:5})
              }
              .width('100%')
              .height(40)
              .borderWidth({
                bottom:1
              })
              .borderColor(Constants.dividerColor2)
              .borderStyle(BorderStyle.Solid)


              Text("场景")
                .fontSize(32)
                .fontColor(Constants.titleColorContext)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ top: 8, bottom: 8, left: 16 })



              //
              // Row() {
              //   Text('场景')
              //     .fontSize(24)
              //     .fontWeight(FontWeight.Bold)
              //     .margin({ left: 16 })
              //
              //   Blank() // 用于将按钮推到右边
              //
              //   Button({ type: ButtonType.Circle, stateEffect: true }) {
              //     Text('+++')
              //       .width(24)
              //       .height(24)
              //   }
              //   .width(40)
              //   .height(40)
              //   .margin({ right: 16 })
              //   .onClick(() => {
              //     this.isAddingContext = true
              //   })
              // }
              // .width('100%')
              // .height(60)
              // .backgroundColor('#F5F5F5')
              // .padding({ left: 16, right: 16 })

              if(this.isAddingContext) {

                NewContextForm({
                  newContextName: this.newContextName,
                  newContextDescription: this.newContextDescription,
                  title: '',
                  description: '',
                  onNewContextNameChange: (value: string) => {
                    this.newContextName = value;
                  },
                  onNewContextDescriptionChange: (value: string) => {
                    this.newContextDescription = value;
                  },
                  onCancel: () => {
                    this.isAddingContext = false;
                  },
                  onSubmit: () => {
                    this.createNewContext();
                    this.newContextName = ''
                    this.newContextDescription = ''
                    this.isAddingContext = false;
                  }
                })
              }


              ContextView({
                tasks: $tasks,
                contexts: $contexts
              })





            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行




          }
          .tabBar(this.TabBuilder("Context", 3, "🏷️"))

          TabContent() {
            // Flagged页面内容
            Column() {

              Row(){
                Blank()
                Button('配置')
                  .fontSize(Constants.fontSizeMedium)
                  .fontWeight(FontWeight.Bold)
                  .backgroundColor(Constants.textColorSecondary)
                  .height(24)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Settings'
                    });
                  })
                  .margin({right:5})
              }
              .width('100%')
              .height(40)
              .borderWidth({
                bottom:1
              })
              .borderColor(Constants.dividerColor2)
              .borderStyle(BorderStyle.Solid)


              Text("已标注")
                .fontSize(32)
                .fontColor(Constants.titleColorStarred)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ top: 8, bottom: 8, left: 16 })

              FlaggedItem({
                tasks: $tasks
              })



            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行

          }
          .tabBar(this.TabBuilder("已标注", 4, "🌟"))

          TabContent() {
            // Flagged页面内容
            Column() {

              ReviewView({
                projects:$projects
              })


            }
            .width('95%')
            .layoutWeight(1)
            .height('100%')
            .alignItems(HorizontalAlign.Start) // 添加这一行

          }
          .tabBar(this.TabBuilder("回顾", 5, "♾"))



        }
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .height('100%')


        if (this.isPopupVisible) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#1a000000')
            .onAppear(() => this.showPopup())
            .onClick(() => this.hidePopup())


          AddTaskComponent({
            context: getContext(this),
            projects: $projects,
            onConfirm: async (record: TaskModel, isUpdate: boolean) => {
              if (isUpdate) {
                const updatedTask = await this.gtdController.updateTask(record);
                hilog.debug(0x009, 'indexPage', `record: ${JSON.stringify(record)}`)
                hilog.debug(0x009, 'indexPage', `${JSON.stringify(updatedTask)}`)
              } else {
                await this.gtdController.createTask(record);
              }

              this.loadTasks();
              this.hidePopup();
              hilog.debug(0x009, 'indexPage', `tasksload:  ${JSON.stringify(this.tasks[1])}`)

            },
            onCancel: () => {
              this.hidePopup();
            }
          })
            .translate({ y: this.popupTranslateY })
            .position({ y: 440 }) // TODO: 需要搞清楚为什么是440

        }


        if (!this.isPopupVisible) {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Text("+")
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .fontSize(30)
              .textAlign(TextAlign.Center)
          }
          .width(40)
          .height(40)
          .margin({ bottom: 160, right: 20 })
          .onClick(() => {
            this.currentEditingTask = { id: -1, name: '', createdDate: new Date(0), isCompleted: false };
            this.showPopup()
          })
        }

      }
      .width('100%')
      // .height(this.StackHeight)
      // .margin({top:this.topMargin})

    }
  }
}
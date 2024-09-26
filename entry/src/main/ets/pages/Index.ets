import { TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import {  TaskList } from '../components/TaskItem'
import { AddTaskComponent } from '../components/AddTask';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import inputMethod from '@ohos.inputMethod';
import { DatabaseGTDDataSource } from '../data/DatabaseGTDDataSource';

@Entry
@Component
struct Index {
  // @Provide gtdController: GTDController = new GTDController();
  @Provide gtdController: GTDController = new GTDController(new DatabaseGTDDataSource());
  @Provide currentEditingTask: TaskModel | {id:-1, name:'', createdDate:Date, isCompleted:boolean } = {id:-1, name:'', createdDate:new Date(0), isCompleted:false};
  @Provide isPopupVisible: boolean = false;

  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;
  @State tasks: TaskModel[] = [];

  @State popupTranslateY: number = 100;



  // private showInputMethod() {
  //   inputMethod.getController().showSoftKeyboard().then(() => {
  //     console.log('Succeeded in showing softKeyboard.');
  //   }).catch((err) => {
  //     console.error('Failed to showSoftKeyboard: ' + JSON.stringify(err));
  //   });
  //
  // }
  //
  // private hideInputMethod() {
  //   inputMethod.getController().hideSoftKeyboard()
  // }


  aboutToAppear() {
    this.gtdController.addObserver(()=>this.loadTasks())
    this.loadTasks();
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



  showPopup() {
    this.isPopupVisible = true;
    animateTo({ duration: 200 }, () => {
      // this.popupOpacity = 1;
      this.popupTranslateY = 0;
      // this.showInputMethod()
    });

  }

  hidePopup() {
    animateTo({ duration: 200,
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

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {

        Stack({ alignContent: Alignment.Bottom }) {
          Column() {
            Text("待办事项")
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .padding({ top: 20, bottom: 10 })

            TaskList({
              tasks:$tasks
            })


          }
          .width('95%')
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Start) // 添加这一行


          if (this.isPopupVisible) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#1a000000')
              .onAppear(() => this.showPopup())
              .onClick(() => this.hidePopup())

            AddTaskComponent({

              context: getContext(this),
              onConfirm: async (record: TaskModel, isUpdate: boolean) => {
                if (isUpdate) {
                  const updatedTask = await this.gtdController.updateTask(record);
                  hilog.debug(0x009,'indexPage',`record: ${JSON.stringify(record)}`)
                  hilog.debug(0x009,'indexPage',`${JSON.stringify(updatedTask)}`)
                  // promptAction.showToast({ message: '更新成功', duration: 2000 });
                } else {
                  await this.gtdController.createTask(record);
                  // promptAction.showToast({ message: '添加成功', duration: 2000 });
                }

                // await this.gtdController.createTask(record);
                this.loadTasks();
                // hilog.debug(0x001,'index',`${JSON.stringify(this.tasks)}`)
                this.hidePopup();
                hilog.debug(0x009,'indexPage',`tasksload:  ${JSON.stringify(this.tasks[1])}`)

              },
              onCancel: () => {
                this.hidePopup();
              }
            })
              .translate({ y: this.popupTranslateY })
          }

          if (!this.isPopupVisible) {
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Text("+")
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .fontSize(30)
                .textAlign(TextAlign.Center)
            }
            .width(60)
            .height(36)
            .margin({ bottom: 30, right: 20 })
            .onClick(() => {
              this.currentEditingTask = {id:-1, name:'', createdDate:new Date(0), isCompleted:false};
              this.showPopup()
            })
          }

        }

      }
      .tabBar(this.TabBuilder("日历", 0, "📅"))

      TabContent() {
        // 项目页面内容
        Text("项目")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("收集箱", 1, "📥"))

      TabContent() {
        // 项目页面内容
        Text("项目")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("项目", 2, "📁"))

      TabContent() {
        // Context页面内容
        Text("Context")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("Context", 3, "🏷️"))

      TabContent() {
        // Flagged页面内容
        Text("Flagged")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("Flagged", 4, "🚩"))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })

  }
}
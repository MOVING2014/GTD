import { TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import {  TaskList } from '../components/TaskItem'
import { EditTaskComponent } from '../components/EditTask';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';

@Entry
@Component
struct Index {
  @Provide gtdController: GTDController = new GTDController();
  @Provide currentEditingTask: TaskModel |null = null;

  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;
  @State tasks: TaskModel[] = [];
  @State isPopupVisible: boolean = false;
  @State popupTranslateY: number = 100;


  aboutToAppear() {
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
    });
  }

  hidePopup() {
    animateTo({ duration: 200,
      onFinish: () => {
        this.isPopupVisible = false;
      }

    }, () => {
      this.popupTranslateY = 350;
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
            Text("收件箱")
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
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
              .backgroundColor('#000000')
              .opacity(0.5)
              .onAppear(() => this.showPopup())

            EditTaskComponent({

              onConfirm: async (record: TaskModel) => {
                // if (isUpdate) {
                //   await this.gtdController.updateTask(record);
                //   promptAction.showToast({ message: '更新成功', duration: 2000 });
                // // } else {
                //   await this.gtdController.createTask(record);
                //   promptAction.showToast({ message: '添加成功', duration: 2000 });
                // // }

                await this.gtdController.createTask(record);
                this.loadTasks();
                // hilog.debug(0x001,'index',`${JSON.stringify(this.tasks)}`)
                this.hidePopup();
                hilog.debug(0x001,'tasksload',`tasksload:  ${JSON.stringify(this.tasks)}`)

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
              this.showPopup()
              // this.currentEditingTask = null;
            })
          }

        }
      }
      .tabBar(this.TabBuilder("收件箱", 0, "📥"))

      TabContent() {
        // 项目页面内容
        Text("项目")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("项目", 1, "📁"))

      TabContent() {
        // Context页面内容
        Text("Context")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("Context", 2, "🏷️"))

      TabContent() {
        // Flagged页面内容
        Text("Flagged")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .tabBar(this.TabBuilder("Flagged", 3, "🚩"))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
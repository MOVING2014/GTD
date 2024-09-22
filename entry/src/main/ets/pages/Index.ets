import { TaskModel } from '../models/IModels';
import { GTDController } from '../viewmodel/GTDController';
import {  TaskList } from '../components/TaskItem'

@Entry
@Component
struct Index {
  @Provide gtdController: GTDController = new GTDController();
  private tabsController: TabsController = new TabsController();
  @State currentIndex: number = 0;
  @State tasks: TaskModel[] = [];


  aboutToAppear() {
    this.loadTasks();
  }

  async loadTasks() {
    try {
      this.tasks = await this.gtdController.getAllTasks();
    } catch (error) {
      console.error('Failed to load tasks:', error);
    }
    this.gtdController.initializeCache()
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

            TaskList()


          }
          .width('95%')
          .layoutWeight(1)
          .height('100%')
          .alignItems(HorizontalAlign.Start) // 添加这一行

          Button({ type: ButtonType.Capsule, stateEffect: true }) {
            Text("+")
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .fontSize(30)
              // .width('100%')
              .textAlign(TextAlign.Center)
          }
          .width(60)
          .height(36)
          .margin({ bottom: 30, right: 20 })
          .onClick(() => {

          })

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
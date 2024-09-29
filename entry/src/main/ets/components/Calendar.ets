// WeekView.ets
import hilog from '@ohos.hilog';
import { isSameDay, parseDate, stringToDate } from '../common/utils';
import { TaskModel } from '../models/IModels';

@Component
export struct WeekView {
  @State recentDays: Date[] = [];
  @State selectedDateString: string = new Date().toString();
  @State updateTrigger: number = 0;
  @Link  tasks: TaskModel[];

  onDateSelect: (date: Date) => void;

  aboutToAppear() {
    this.initializeRecentDays();
  }

  private initializeRecentDays() {
    const today = new Date();
    this.recentDays = Array.from({ length: 7 }, (_, i) => {
      const date = new Date(today);
      date.setDate(today.getDate() - (1 - i));
      return date;
    });
  }

  private formatDayOfWeek(date: Date): string {
    const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return days[date.getDay()];
  }

  private isToday(date: Date): boolean {
    const today = new Date();
    return date.getDate() === today.getDate() &&
    date.getMonth() === today.getMonth() &&
    date.getFullYear() === today.getFullYear();
  }

  private isSelected(date: Date): boolean {

    return date.getDate() === stringToDate(this.selectedDateString).getDate() &&
    date.getMonth() === stringToDate(this.selectedDateString).getMonth() &&
    date.getFullYear() === stringToDate(this.selectedDateString).getFullYear();
  }

  private getUncompletedTaskCount(date: Date): number {
     let len = this.tasks.filter(task => {
      if(!task.dueDate) return false;
      const taskDate = task.dueDate;
      hilog.debug(0x002,'Calendar',`taskid:${task.title} taskDate:${taskDate},date: ${date}, ${isSameDay(date, taskDate).toString()}`);
      return isSameDay(date, taskDate) && !task.isCompleted; // 假设任务模型有 completed 属性
    }).length;

    return len
  }



  build() {
    Row() {
      ForEach(this.recentDays, (day, index) => {
        Column() {
          Row() {
            Text(this.formatDayOfWeek(day))
              .fontSize(10)
              .fontColor('#666666')
              .fontWeight(FontWeight.Bold)
              .margin({right:3})

            Text(day.getDate().toString())
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isToday(day) ? '#666666' : '#666666')

          }.margin({top:10})
          .width('70%')
          .justifyContent(FlexAlign.SpaceAround)

          Blank()

          Text(this.getUncompletedTaskCount(day).toString())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isToday(day) ? '#666666' : '#666666')
            .margin({ bottom: 10 })
        }
        .width(50)
        .height(60)
        .margin({ right: 5 })
        .borderRadius(8)
        .backgroundColor(this.isSelected(day) ? '#79007aff' :
          this.isToday(day) ? '#1dff003b' : '#F0F0F0')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.selectedDateString = day.toString()
          this.updateTrigger++
          this.onDateSelect(day); // 需要触发任务的过滤动作
        })
      },
        day => `${day} - ${this.updateTrigger}`
      )
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    .padding({ left: 5, right: 5, top: 10, bottom: 10 })
  }
}
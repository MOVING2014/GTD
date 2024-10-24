// WeekView.ets
import hilog from '@ohos.hilog';
import { Constants } from '../common/Constants';
import { isSameDay, parseDate, stringToDate } from '../common/utils';
import { TaskModel } from '../models/IModels';

@Component
export struct WeekView {
  @State recentDays: Date[] = [];
  @State selectedDateString: string  = new Date().toString();
  @State updateTrigger: number = 0;
  @Link  tasks: TaskModel[];

  onDateSelect: (date: Date |'') => void;

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

  private isYesterday(date: Date): boolean {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);

    return date.getDate() === yesterday.getDate() &&
    date.getMonth() === yesterday.getMonth() &&
    date.getFullYear() === yesterday.getFullYear();
  }


  private isFuture(date: Date): boolean {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() + 5);

    return date.getDate() === yesterday.getDate() &&
    date.getMonth() === yesterday.getMonth() &&
    date.getFullYear() === yesterday.getFullYear();
  }



  private isSelected(date: Date): boolean {
    if (!this.selectedDateString) return false;
    return date.getDate() === stringToDate(this.selectedDateString).getDate() &&
    date.getMonth() === stringToDate(this.selectedDateString).getMonth() &&
    date.getFullYear() === stringToDate(this.selectedDateString).getFullYear();
  }

  // private getUncompletedTaskCount(date: Date): number {
  //    let len = this.tasks.filter(task => {
  //     if(!task.dueDate) return false;
  //     const taskDate = task.dueDate;
  //     // hilog.debug(0x002,'Calendar',`taskid:${task.title} taskDate:${taskDate},date: ${date}, ${isSameDay(date, taskDate).toString()}`);
  //     return isSameDay(date, taskDate) && !task.isCompleted; // 假设任务模型有 completed 属性
  //   }).length;
  //
  //   return len
  // }
  //

  private getUncompletedTaskCount(date: Date): number {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const targetDate = new Date(date);
    targetDate.setHours(23, 59, 59, 999);

    const futureDateThreshold = new Date(today);
    futureDateThreshold.setDate(today.getDate() + 5);
    futureDateThreshold.setHours(0, 0, 0, 0);

    if (targetDate.getTime() < today.getTime()) {
      hilog.debug(0x001, 'Calendar', `target Date: ${targetDate.toString()}/ today: ${today.toString()}`)
    }

    return this.tasks.filter(task => {
      if (!task.dueDate) return false;
      const taskDate = new Date(task.dueDate);

      if (targetDate.getTime() < today.getTime()) {
        // 对于昨天及之前的日期
        return taskDate.getTime() <= targetDate.getTime() && !task.isCompleted;
      } else if (targetDate.getTime() >= futureDateThreshold.getTime()) {
      // 对于今天之后的第5天及以后的日期
      return taskDate.getTime() >= futureDateThreshold.getTime() && !task.isCompleted;
      } else {
        // 对于今天及将来的日期
        return isSameDay(taskDate, targetDate) && !task.isCompleted;
      }
    }).length;
  }



  build() {

    Column() {
      Row() {
        ForEach(this.recentDays, (day, index) => {
          Column() {
            Row() {
              Text(this.isToday(day) ? '今天' : (this.isYesterday(day) ? '过去' : this.isFuture(day) ? '未来' : this.formatDayOfWeek(day)))
                .fontSize(12)
                .fontColor(this.isToday(day) ? '#b9990000' : '#666666')
                .fontWeight(FontWeight.Bold)
              // .margin({right:3})

              Text(day.getDate().toString())
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isToday(day) ? '#666666' : '#666666')

            }.margin({ top: 6 })
            // .width('100%')
            .justifyContent(FlexAlign.Center)

            Blank()

            Text(this.getUncompletedTaskCount(day).toString())
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isToday(day) ? '#666666' : '#666666')
              .margin({ bottom: 6 })
          }
          .width(54)
          .height(56)
          // .margin({ right: 5 })
          .backgroundColor(this.isSelected(day) ? '#57cecccc' :
            this.isToday(day) ? '#FFFFFF' : '#FFFFFF')
          .justifyContent(FlexAlign.Center)
          .borderWidth({
            top: this.isSelected(day) ? 2.5 : 0
          })
          .borderColor(Constants.dateSelectedColor)
          .borderStyle(BorderStyle.Solid)
          .onClick(() => {

            if (this.isSelected(day)) {
              // 如果点击的是已选中的日期，则取消选中
              this.selectedDateString = '';
              this.onDateSelect('');
            } else {
              // 否则选中新的日期
              this.selectedDateString = day.toString();
              hilog.debug(0x002, 'Calendar', `${this.selectedDateString}`)
              this.onDateSelect(day);
            }
            // this.selectedDateString = day.toString()
            this.updateTrigger++
            // this.onDateSelect(day); // 需要触发任务的过滤动作
          })
        },
          day => `${day} - ${this.updateTrigger}`
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .borderWidth({
        bottom:1
      })
      .borderColor(Constants.dividerColor2)
      .borderStyle(BorderStyle.Solid)

    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 0, bottom:8 })


  }
}
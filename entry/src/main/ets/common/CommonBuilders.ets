
import { TaskModel } from '../models/IModels'
import { GTDController } from '../viewmodel/GTDController'
import { formatDate, formatDateToChinese, overDue } from './utils'


@Builder export function ProjectLabel(projectId: number, controller: GTDController) {
  if (projectId) {
    Row() {
      Text(controller.projectCache[projectId]?.name || '')
        .fontSize(16)
        .fontColor('#666666')
        .backgroundColor('#F0F0F0')
        .borderRadius(4)
          // .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .margin({ right: 8, top:5 })
    }
  }
}


@Builder export function ContextLabel(contextId: number, controller: GTDController) {
  if (contextId) {
    Row() {
      Text(controller.contextCache[contextId]?.name || '')
        .fontSize(16)
        .fontColor('#666666')
        .backgroundColor('#F0F0F0')
        .borderRadius(4)
        .margin({ right: 8, top:5 })
    }
  }
}


@Builder export  function TaskItem(task: TaskModel, gtdController: GTDController, loadTasks: () => void) {
  Row() {
    Toggle({ type: ToggleType.Checkbox, isOn: task.isCompleted })
      .onChange((isOn: boolean) => {
        task.isCompleted = isOn;
        task.modifyTime = new Date();
        gtdController.updateTask(task).then(() => {
          loadTasks();
          console.info('Task updated successfully');
        }).catch(error => {
          console.error('Failed to update task:', error);
        });
      })
      .margin({ right: 10 })
      .alignSelf(ItemAlign.Start)



    Column() {
      Text(task.flagged? '🌟'+ task.title : task.title)
        .fontSize(18)
        .fontColor(task.isCompleted ? '#888888' : '#000000')
        // .fontWeight(task.flagged? FontWeight.Bold : FontWeight.Bold)
        .fontWeight(FontWeight.Bold)
        .decoration({ type: task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
        .width('85%')
        .alignSelf(ItemAlign.Start)

      Row() {
        if (task.projectId) {
          ProjectLabel(task.projectId, gtdController)
        }
        if (task.contextId) {
          ContextLabel(task.contextId, gtdController)
        }
        if (task.dueDate) {
          Text(formatDateToChinese(task.dueDate, false))
            .fontSize(16)
            .fontColor(overDue(task.dueDate) ? '#FF0000' : '#888888')
            .margin({ top: 5 })
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
  .width('100%')
  .padding(10)
  .borderRadius(8)
  .backgroundColor(Color.White)
  .margin({ bottom: 10 })
  .alignItems(VerticalAlign.Top)
}
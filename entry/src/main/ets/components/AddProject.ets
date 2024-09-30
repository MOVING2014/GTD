// common/ProjectForms.ets

@Component
export struct NewProjectForm {
  @Prop newProjectName: string;
  @Prop newProjectDescription: string;
  @Consume taskUpdateTrigger: number;

  @Prop title: string;
  @Prop description: string;
  onNewProjectNameChange: (value: string) => void;
  onNewProjectDescriptionChange: (value: string) => void;
  onCancel: () => void;
  onSubmit: () => void;

  aboutToAppear(){

  }

  build() {
    Column() {
      TextInput({ placeholder: '新项目名称',
      text: this.title
      })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.onNewProjectNameChange(value);
        })
        .margin({ bottom: 3 })

      TextInput({ placeholder: '备注/项目目标？',
      text: this.description
      })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.onNewProjectDescriptionChange(value);
        })
        .margin({ bottom: 3 })

      Row() {
        Button('取消')
          .onClick(() => {
            this.onCancel();
          })
        Button('确认')
          .onClick(() => {
            this.onSubmit();
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('60%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }
}
// common/ProjectForms.ets

@Component
export struct NewContextForm {
  @Prop newContextName: string;
  @Prop newContextDescription: string;
  @Consume taskUpdateTrigger: number;

  @Prop title: string;
  @Prop description: string;
  onNewContextNameChange: (value: string) => void;
  onNewContextDescriptionChange: (value: string) => void;
  onCancel: () => void;
  onSubmit: () => void;

  aboutToAppear(){

  }

  build() {
    Column() {
      TextInput({ placeholder: '新Context',
        text: this.title
      })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.onNewContextNameChange(value);
        })
        .margin({ bottom: 3 })

      TextInput({ placeholder: '说明信息',
        text: this.description
      })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.onNewContextDescriptionChange(value);
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
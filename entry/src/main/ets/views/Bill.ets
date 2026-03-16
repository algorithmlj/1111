@Component
export struct Bill {

  build() {
    Column({space:10}) {
      Text("账单")
    }
    .height('100%')
    .width('100%')
  }
}
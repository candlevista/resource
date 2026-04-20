import { HMLifecycleState, HMRouter, HMRouterMgr, NavDestinationHelper, NavigationHelper } from '@hadss/hmrouter';
import { FlutterEntry, FlutterPage, FlutterView, Log } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';

@HMRouter({ pageUrl: "JJSFlutterPage", useNavDst: true })
@Component
export struct JJSFlutterPage {
  private context = getContext(this) as common.UIAbilityContext
  private flutterEntry: FlutterEntry | null = null;
  @State private flutterViewId: string = ''
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      if (this.flutterViewId !== '') {
        FlutterPage({ viewId: this.flutterViewId })
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.init(context)
    })
    .onDisAppear(() => {
      this.flutterEntry?.aboutToDisappear()
    })
    .onShown(() => {
      this.flutterEntry?.onPageShow()
    })
    .onHidden(() => {
      this.flutterEntry?.onPageHide()
    })
    .onBackPressed(() => {
      this.context.eventHub.emit('EVENT_BACK_PRESS')
      return true
    })
  }

  init(context: NavDestinationContext) {
    let pathStack = context.pathStack
    this.pathStack = pathStack;
    let array = pathStack.getParamByName('JJSFlutterPage') as Array<Record<string, Object>>;
    let params: Record<string, Object> = array.length > 0 ? array[0] : {};
    this.flutterEntry = new NavFlutterEntry(getContext(this), params, pathStack)
    this.flutterEntry.aboutToAppear()
    const flutterView: FlutterView | undefined = this.flutterEntry?.getFlutterView()
    if (flutterView) {
      this.flutterViewId = flutterView.getId()
      this.flutterEntry.onPageShow()
    }
  }
}

class NavFlutterEntry extends FlutterEntry {
  pathStack?: NavPathStack;

  constructor(context: Context, params: Record<string, Object> = {}, pathStack?: NavPathStack) {
    super(context, params)
    this.pathStack = pathStack;
  }

  popSystemNavigator(): boolean {
    if (this.pathStack) {
      this.pathStack.pop();
      return true;
    }
    return false;
  }
}

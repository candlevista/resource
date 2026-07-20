import { HMRouter } from '@hadss/hmrouter';
import { FlutterEntry, FlutterEngine, FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import FlutterAbilityLaunchConfigs from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterAbilityLaunchConfigs';
import { common } from '@kit.AbilityKit';
import { isBlankString } from 'utils/src/main/ets/utils/CommonUtil';
import NativeBridgePlugin from './plugin/NativeBridgePlugin';
import { FlutterRoute } from './FlutterRoute';
import { GeneratedPluginRegistrant } from '@ohos/flutter_module';

@HMRouter({ pageUrl: "JJSFlutterPage", useNavDst: true })
@Component
export struct JJSFlutterPage {
  private context = getContext(this) as common.UIAbilityContext
  private flutterEntry: FlutterEntry | null = null;
  @State private flutterViewId: string = ''
  private routePath: string = FlutterRoute.HOME
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
    const pathStack = context.pathStack
    this.pathStack = pathStack;
    const array = pathStack.getParamByName('JJSFlutterPage') as Array<Record<string, Object>>;
    const routerParams: Record<string, Object> = array.length > 0 ? array[0] : {};
    this.routePath = this.resolveRoute(routerParams);
    const flutterParams = this.buildFlutterEntryParams(this.routePath);
    this.flutterEntry = new NavFlutterEntry(getContext(this), flutterParams, pathStack)
    this.flutterEntry.aboutToAppear()
    const flutterView: FlutterView | undefined = this.flutterEntry?.getFlutterView()
    if (flutterView) {
      this.flutterViewId = flutterView.getId()
      this.flutterEntry.onPageShow()
    }
  }

  private resolveRoute(params: Record<string, Object>): string {
    const route = params['route'];
    if (route !== null && route !== undefined) {
      const routeStr = String(route);
      if (!isBlankString(routeStr)) {
        return routeStr;
      }
    }
    return FlutterRoute.HOME;
  }

  private buildFlutterEntryParams(route: string): Record<string, Object> {
    const flutterParams: Record<string, Object> = {};
    flutterParams[FlutterAbilityLaunchConfigs.EXTRA_INITIAL_ROUTE] = route;
    return flutterParams;
  }
}

class NavFlutterEntry extends FlutterEntry {
  pathStack?: NavPathStack;

  constructor(context: Context, params: Record<string, Object> = {}, pathStack?: NavPathStack) {
    super(context, params)
    this.pathStack = pathStack;
  }

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    // 注册 path_provider_ohos、sqflite_ohos 等，否则 CachedNetworkImage 会 channel-error
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins()?.add(new NativeBridgePlugin());
  }

  popSystemNavigator(): boolean {
    if (this.pathStack) {
      this.pathStack.pop();
      return true;
    }
    return false;
  }
}

public class OBICanvasLifecycleHandler 
implements Canvas.CanvasLifecycleHandler {

    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();

        // Code goes here to add items to excluded list
        // that should be excluded from Context data

        return excluded;
    }

    public void onRender(Canvas.RenderContext renderContext) {

        // Code goes here to customize behavior when the app is rendered

    }
}
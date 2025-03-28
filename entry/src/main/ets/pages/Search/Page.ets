@ComponentV2
struct Page {
    build() {
        NavDestination() {

        }
        .hideTitleBar(true)
    }
}

@Builder
export function PageBuilder() {
    Page()
}
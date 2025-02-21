@ComponentV2
struct Page {
    build() {
        NavDestination() {

        }
        .title('期刊分期列表')
    }
}

@Builder
export function PageBuilder() {
    Page()
}
use warp::Filter;

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let hello_world = warp::path::end().map(|| {
        format!(
            "Hello World!\nCurrent version: {}\n",
            env!("CARGO_PKG_VERSION")
        )
    });

    let hi = warp::path("hi").map(|| "Hi!\n");

    let hello = warp::path!("hello" / String).map(|name| format!("Hello, {}!\n", name));

    let version = warp::path("version").map(|| env!("CARGO_PKG_VERSION"));

    let routes = warp::get().and(hello_world.or(hi).or(hello).or(version));

    warp::serve(routes).run(([0, 0, 0, 0], 3030)).await;
}

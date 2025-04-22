# ExSnappy

GetSnappy is a visual regression testing tool, ExSnappy is used to generate HTML for rendering by GetSnappy.

## Installation

```elixir
def deps do
  [
    {:ex_snappy, "~> 0.1.0"}
  ]
end
```

## Configuration

There's currently a little bit of ceremony to get the service running, due to a couple of quirks in how testing works for components and LiveView in the testing environment.

When a live view is rendered with the `live(...)` function, you get back the full HTML, which includes the necessary `<head>` content which loads your CSS.

Unfortunately if you use any of the `render_x(...)` calls, you only get back a subset of the HTML, similarly if you use `render_component` you get the HTML from the individual component, but none of the HTML responsible for loading styles.

Currently the way to deal with this is to provide `wrapper_fn` function in `test.exs`.  In future we aim to provide a more ergonomic way using your application's templates directly.

This is essentially the contents of your `root.html.heex`, plus the content of `app.html.heex`.  

**NOTE** Don't add references to load JavaScript.  The reason for this is you don't really want to connect the websocket and have a second page render or deal with things like the 'topbar', which will cause you to have inconsistent images due to timing issues.

```elixir
config :ex_snappy,
  wrapper_fn: fn inner_content ->
      """
      <!DOCTYPE html>
      <html lang="en" class="[scrollbar-gutter:stable]">
      <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <link phx-track-static rel="stylesheet" href="/assets/app.css" />
      </head>
      <body class="bg-white antialiased dark:bg-gray-900 dark:text-gray-100">
      <main>
      #{inner_content}
      </main>
      </body>
      </html>
      """
  end
```

If you're running tests locally, you likely don't want to be running the visual regression tests, so we only execute if you explicitly enable things.  Suggested way of dealing with this below

```elixir
config :ex_snappy,
  enabled: System.get_env("EX_SNAPPY_ENABLED") == "true"
```

If you don't wish your screenshots to be full_page you can turn this off globally

```elixir
config :ex_snappy,
  full_page: false
```

# Setup

To execute the visual regression tests, you'll need to install the binary from https://get-snappy.com/app/downloads 

And add some configuration data by creating a `.get-snappy.yml` file

The `local_dist_dir` is use to allow the rendering service to know where your static assets are.  For most Phoenix projects, this would be `priv/static`

`snappy_workers` are the number of workers per browser.  This allows faster rendering of snapshots, but can be reduced if you are resource limited.  In the example below there would be a total of 12 browser instances (4 x 3 browser).

`browsers` Are the browsers you wish to render in

`test_command` is the shell command you wish to run to execute your test suite.

```yml
local_dist_dir: "priv/static"
snappy_workers: 4
test_command: "mix do assets.build, mix test"
browsers: ["chrome", "webkit", "firefox"]
```

You'll also need to set some environment variables, an example of this is below, but you'd likely get the COMMIT and BRANCH from your CI provider.

```shell
COMMIT=$(git rev-parse HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

export GET_SNAPPY_API_KEY="your-project-api-ket"
export GET_SNAPPY_COMMIT=$COMMIT
export GET_SNAPPY_BRANCH=$BRANCH
```

Finally, execute the tests you'd run something like this (further information on `EX_SNAPPY_ENABLED` below):

`EX_SNAPPY_ENABLED=true  ./get-snappy snapshot-run`

## Usage

The `snap` macro can be used in three forms.  See `ExSnappy` module for further details.

Key steps: 

1. `import ExSnappy` to make the `snap` macro available

2. Use the `snap` function to capture screenshots.  **NOTE** Screenshot names are automatically generated based on the name of the `test` function, but if you take multiple screenshots in a single test, you'll need to provide an explicit name to be appended to the test name.

```elixir
defmodule MyApp.LiveIndexTest do
  use MyApp.ConnCase, async: true
  import Phoenix.LiveViewTest

  import ExSnappy
end
```

Then to use in tests, you need send HTML.  This can be achieved by calling `render` only your `live` process, passing the `html` generated from a `live()` call, or the `html` generated from the `render_component` function.

### Rendering from `live()`

```elixir
defmodule MyApp.LiveIndexTest do
  use MyApp.ConnCase, async: true
  import Phoenix.LiveViewTest

  import ExSnappy
  
  describe "my tests" do
    test "List projects and project builds", %{conn: conn, project: project} do
      # Visit top level builds page
      {:ok, index_live, html} = live(conn, ~p"/app/builds")

      assert html =~ "Builds"
      assert html =~ project.name

      snap(html)
    end
  end
end
```

### Using `render()`


```elixir
defmodule MyApp.LiveIndexTest do
  use MyApp.ConnCase, async: true
  import Phoenix.LiveViewTest

  import ExSnappy
  
  describe "my tests" do
    test "List projects and project builds", %{conn: conn, project: project} do
      # Visit top level builds page
      {:ok, index_live, html} = live(conn, ~p"/app/builds")

      assert html =~ "Builds"
      assert html =~ project.name

      snap(render(index_live))
    end
  end
end
```

### Using `render_component()`

```elixir
defmodule MyApp.PaginationGeneratorTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import ExSnappy

  test "Lists elements when no next or previous" do
    meta = %Flop.Meta{
      current_page: 1,
      total_pages: 10
    }

    rendered = render_component(&MyApp.Pagination.paginate/1, meta: meta, base_url: "/hello")

    snap(rendered)

    assert Floki.find(rendered, "a") |> length() == 10
  end
end
```

# Taking multiple screenshots in a single test

Simply provide an explicit name for all but the first call to `snap`.

```elixir
   test "multiple screenshots" do
      {:ok, index_live, html} = live(conn, ~p"/app/projects")

      snap(html)

      assert index_live |> element("a", "New Project") |> render_click() =~
               "New Project"

      render_async(index_live)

      snap(render(index_live), name: "after render" )

      assert index_live
             |> form("#project-form", project: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      snap( render(index_live), name: "With errors")

      assert index_live
             |> form("#project-form",
               project:
                 @create_attrs
                 |> Map.put(:repository_full_name, "some/repo")
             )
             |> render_submit()

      snap(render(index_live), name: "With errors fixed")
   end
```
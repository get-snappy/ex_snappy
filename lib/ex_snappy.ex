defmodule ExSnappy do
  @moduledoc """
  ExSnappy is a library for taking snapshots of HTML using the Go Snappy service.
  """

  @doc """
  Takes a snapshot of the given HTML and sends it to the Go Snappy service.

  Uses the name of the test function as the snapshot name.

  You can explicitly set the name of the snapshot by passing the `:name` option.

  By default, any <script> tags in the HTML will be removed before sending to the Go Snappy service.
  This is to ensure that the DOM will not be modified when processed for screenshots.

  Other options will be passed to the Go Snappy service, such as setting dimensions.

  You can also pass `:playwright_options` to set options for Playwright.  



  # Playwright Options

  These are passed via `:playwright_options`.

  `:full_page` - when `true`, takes a screenshot of the full scrollable page, instead of the
  currently visible viewport. Defaults to `false`. You can globally set this in config using
  `:full_page`.

  `:locator` - CSS selector or Playwright locator string to target a specific element for the
  screenshot.

  `:dark_mode` - enable dark mode rendering for the snapshot. Defaults to `false`.

  `:animations` - when set to `false`, stops CSS animations, CSS transitions, and Web Animations.
  Finite animations are fast-forwarded to completion (so they'll fire `transitionend`), and
  infinite animations are canceled to initial state, then played over after the screenshot.
  Defaults to `false`.

  `:mask` - array of CSS selectors to mask (hide) in the snapshot. Masked elements are overlaid
  with a colored box (default pink `#FF00FF`).

  `:mask_color` - color to use for masked regions, in CSS color format. Defaults to pink.

  `:omit_background` - hides default white background and allows capturing screenshots with
  transparency. Not applicable to JPEG images. Defaults to `false`.

  `:clip` - clip a specific region of the page: `%{x: number, y: number, width: number, height: number}`.

  `:scale` - when set to `"css"`, screenshot has a single pixel per CSS pixel. When set to
  `"device"`, screenshot has a single pixel per device pixel. Defaults to `"device"`.

  `:caret` - when set to `"hide"`, screenshot will hide text caret. When set to `"initial"`,
  text caret behavior will not be changed. Defaults to `"hide"`.

  # Options

  `:dimensions`, which can be a list of maps with `:width` and `:height` keys.  
  Where dimensions aren't specified, the default will be 1920x1080

  `:precision_threshold`, the match level below which the comparison will fail. Range: 0-100.


  ## Example

  ```elixir
  snap(html, name: "my_snapshot", 
    playwright_options: %{
      full_page: false,
      dark_mode: true,
      locator: ".my-element"
    },
    dimensions: [
      %{width: 1280, height: 720},
      %{width: 1920, height: 1080}
    ]
  )
  ```

  """
  defmacro snap(html, options \\ []) do
    if Application.get_env(:ex_snappy, :enabled) do
      function_name = __CALLER__.function

      quote bind_quoted: [function_name: function_name, options: options, html: html] do
        test_name =
          case Keyword.get(options, :name) do
            nil -> ExSnappy.Utils.generate_test_name(function_name, nil)
            name -> ExSnappy.Utils.generate_test_name(function_name, name)
          end

        ExSnappy.API.process_snapshot(test_name, html, options)
      end
    else
      html
    end
  end
end

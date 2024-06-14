# Constant Testing
## Monitors Elixir projects and when it detects a file update it will run the tests for that file

Run this in your elixir project (or at the root of your umbrella project) and when you update a .exs file it will run the tests from that file. If you update a .ex file it will look for a corresponding .exs file and run those tests

### Usage

1. Clone the repo
  ```shell
  git clone https://github.com/danturn/constant_testing.git
  ```

2. Set it up wherever you want it
  ```shell
  cd constant_testing
  ./setup_in.sh ~/bin
  ```

3. Run constant testing
  ```shell
    constant_testing
  ```

4. Start writing code!


### Usage Varients

1. `constant_testing`
if a `*.exs` or `*.ex` file is saved, then
`mix test /path/to/the/relevant/file.exs`
will be run, with the path being worked-out from whichever path was saved.

2. `constant_testing /path/to/a/specific/elixir/test.exs`
regardless of what `.ex` or `.exs` files are saved, will run
`mix test /path/to/a/specific/elixir/text.exs`

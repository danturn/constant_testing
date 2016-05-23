# Constant Testing
## Monitors elixir projects and automatically runs tests when files are edited.

Run this in your elixir project (or at the root of your umbrella project) and when you update a .exs file it will run the tests from that file. If you update a .ex file it will look for a corresponding .exs file and run those tests

### Usage

1. Clone the repo
  ```shell
  git clone https://github.com/danturn/constant_testing.git
  ```
  
2. Set it up for your Elixir project:
  ```shell
  cd constant_testing
  ./setup_in.sh ~/src/my_lovely_project
  ```

3. Run constant testing in your Elixir project
  ```shell
  cd ~/src/my_lovely_project
  ./constant-testing.sh
  ```

4. Start writing code!

## Development

### Dev setup

There 3 ways to interact with this project:

1) Using Docker:

```sh
# Run rails server on the dummy app (=> http://localhost:3000 to access to ActiveAdmin):
make up
# Enter in a Rails console (with the dummy app started):
make console
# Enter in a shell (with the dummy app started):
make shell
# Run the linter on the project (with the dummy app started):
make lint
# Run the test suite (with the dummy app started):
make specs
# Remove container and image:
make cleanup
# To try different versions of Ruby/Rails/ActiveAdmin:
RUBY=3.2 RAILS=7.1.0 ACTIVEADMIN=3.2.0 make up
# For more commands please check the Makefile
```

2) Using Appraisal:

```sh
export RAILS_ENV=development
# Install dependencies:
bin/appraisal
# Run server (or any command):
bin/appraisal rails s
# Or with a specific configuration:
bin/appraisal rails80-activeadmin rails s
```

3) With a local setup:

```sh
# Dev setup (set the required envs):
source extra/dev_setup.sh
# Install dependencies:
bundle update
# Run server (or any command):
bin/rails s
# To try different versions of Rails/ActiveAdmin edit extra/dev_setup.sh
```

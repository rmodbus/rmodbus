Contributing
=====================

rmodbus is work of [many contributors](https://github.com/rmodbus/rmodbus/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/rmodbus/rmodbus/pulls), [propose features and discuss issues](https://github.com/rmodbus/rmodbus/issues).

#### Fork the Project

Fork the [project on Github](https://github.com/rmodbus/rmodbus) and check out your copy.

```
git clone https://github.com/[your-name]/rmodbus.git
cd rmodbus
git remote add upstream https://github.com/rmodbus/rmodbus.git
```

#### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

#### Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rspec
```

#### Write Code

Implement your feature or bug fix.

We appreciate pull requests with test cases to prevent regressions.

#### Commit Changes

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/[your-name]/rmodbus and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

#### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster with Travis-CI. Everything should look green, otherwise fix issues and amend your commit as described above.

#### Thank You

We really appreciate and value your time and work. Thank you for making rmodbus better!

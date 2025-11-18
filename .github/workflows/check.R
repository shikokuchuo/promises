pkgload::load_all()
library(testthat)
test_file("tests/testthat/test-cpp.R", reporter = check_reporter())

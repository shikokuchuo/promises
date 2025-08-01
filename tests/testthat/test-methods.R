library(testthat)

describe("then()", {
  it("honors .visible argument", {
    result <- NULL
    p <- promise(\(resolve, reject) resolve(invisible(1))) |>
      then(function(value, .visible) {
        result <<- list(value = value, visible = .visible)
      })
    p |> wait_for_it()
    expect_identical(result$value, 1)
    expect_identical(result$visible, FALSE)

    p <- promise(\(resolve, reject) resolve(1)) |>
      then(function(value, .visible) {
        result <<- list(value = value, visible = .visible)
      })
    p |> wait_for_it()
    expect_identical(result$value, 1)
    expect_identical(result$visible, TRUE)

    # .visible is preserved even with an intermediate then() or catch()
    p <- promise(\(resolve, reject) resolve(invisible(1))) |>
      then() |>
      catch(\(err) "what error?") |>
      then(function(value, .visible) {
        result <<- list(value = value, visible = .visible)
      })
    p |> wait_for_it()
    expect_identical(result$value, 1)
    expect_identical(result$visible, FALSE)
  })
  it("method ignores non-functions or NULL...", {
    p1 <- promise(\(resolve, reject) resolve(1))
    expect_warning(
      {
        p1 <- p1$then(10)
      },
      "`onFulfilled` must be a function or `NULL`",
      fixed = TRUE
    )
    expect_warning(
      {
        p1 <- p1$then(NULL)
      },
      NA
    )
    expect_identical(extract(p1), 1)
  })
  it("...but function only ignores NULL, not non-functions", {
    expect_error(promise(\(resolve, reject) resolve(1)) |> then(10))
    expect_error(promise(\(resolve, reject) resolve(1)) |> then(NULL), NA)
  })

  it("honors visibility with no .visible argument", {
    result <- NULL
    p <- promise_resolve(invisible(1))$then(function(value) {
      result <<- withVisible(value)
    })
    p |> wait_for_it()
    expect_identical(result$value, 1)
    expect_identical(result$visible, FALSE)

    result <- NULL
    p <- promise_resolve(2)$then(function(value) {
      result <<- withVisible(value)
    })
    p |> wait_for_it()
    expect_identical(result$value, 2)
    expect_identical(result$visible, TRUE)
  })
})

describe("catch()", {
  it("catches", {
    p <- ext_promise()
    p2 <- p$promise |> catch(\(err) TRUE)
    p$reject("boom")
    expect_identical(extract(p2), TRUE)
  })
  it("can throw", {
    p <- promise(\(resolve, reject) stop("foo")) |> catch(\(err) stop("bar"))
    expect_error(extract(p), "^bar$")
  })
  it("method ignores non-functions or NULL...", {
    p1 <- promise(\(resolve, reject) resolve(1))
    expect_warning(
      {
        p1 <- p1$catch(10)
      },
      "`onRejected` must be a function or `NULL`",
      fixed = TRUE
    )
    expect_warning(
      {
        p1 <- p1$catch(NULL)
      },
      NA
    )
    expect_identical(extract(p1), 1)
  })
  it("...but function only ignores NULL, not non-functions", {
    expect_error(promise(\(resolve, reject) resolve(1)) |> catch(10))
    expect_error(promise(\(resolve, reject) resolve(1)) |> catch(NULL), NA)
  })
})

describe("finally()", {
  it("calls back when a promise is resolved", {
    called <- FALSE
    p <- promise(\(resolve, reject) resolve(10)) |>
      finally(\() {
        called <<- TRUE
      })
    p |> wait_for_it()
    expect_identical(called, TRUE)
    expect_identical(extract(p), 10)
  })
  it("calls back when a promise is rejected", {
    called <- FALSE
    p <- promise(\(resolve, reject) reject("foobar"))
    p |>
      finally(\() {
        called <<- TRUE
      }) |>
      squelch_unhandled_promise_error() |>
      wait_for_it()
    expect_identical(called, TRUE)
    expect_error(extract(p), "^foobar$")
  })
  it("does not affect the return value of the promise", {
    p1 <- promise(\(resolve, reject) resolve(1)) |>
      finally(\() {
        20
      })
    expect_identical(extract(p1), 1)

    p2 <- promise(\(resolve, reject) reject("err")) |>
      finally(\() {
        20
      })
    expect_error(extract(p2), "^err$")
  })
  it("errors replace the result of the promise", {
    p1 <- promise(\(resolve, reject) resolve(1)) |>
      finally(\() {
        stop("boom")
      })
    expect_error(extract(p1), "^boom$")

    p2 <- promise(\(resolve, reject) reject("foo")) |>
      finally(\() {
        stop("bar")
      })
    expect_error(extract(p2), "^bar$")
  })
  it("method ignores non-functions or NULL...", {
    p1 <- promise(\(resolve, reject) resolve(1))$finally(10)$finally(NULL)
    expect_identical(extract(p1), 1)
  })
  it("...but function only ignores NULL, not non-functions", {
    expect_error(promise(\(resolve, reject) resolve(1)) |> finally(10))
    expect_error(promise(\(resolve, reject) resolve(1)) |> finally(NULL), NA)
  })
})

describe("future", {
  it("is treated as promise when used as resolution", {
    p <- promise_resolve(future::future(1))
    expect_identical(extract(p), 1)

    p2 <- promise_resolve(future::future(stop("boom")))
    expect_error(extract(p2))
  })

  it("is treated as promise when used as resolution", {
    p <- promise_reject(future::future(1))
    expect_identical(extract(p), 1)

    p2 <- promise_reject(future::future(stop("boom")))
    expect_error(extract(p2))
  })
})

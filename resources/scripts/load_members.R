library(readxl, quietly = TRUE)
library(htmltools, quietly = TRUE)
library(yaml, quietly = TRUE)

members_excel <- readxl::read_excel("../resources/scripts/group_info.xlsx", sheet = "Current group members", skip = 2)
past_members <- readxl::read_excel("../resources/scripts/group_info.xlsx", sheet = "Past members", skip = 0)

members_2_yaml <-
  members_excel |>
  dplyr::filter(!is.na(Name)) |>
  dplyr::group_by(Name) |>
  dplyr::mutate(
    dummy_list = list(list(
      title = dplyr::if_else(is.na(Name), "", Name),
      categories = list(dplyr::if_else(is.na(Position), "", Position)),
      description = dplyr::if_else(is.na(Interests), "", Interests),
      image = suppressWarnings(
        ifelse(
          is.null(members_excel$image),
          glue::glue("/img/green_series_01.webp"), glue::glue('{image}')
        )
      )
    ))
  ) |>
  dplyr::pull(dummy_list)

yaml::write_yaml(members_2_yaml, "../resources/scripts/actual_members.yml")

past_members_html <- htmltools::tagList()

for (index in 1:nrow(past_members)) {
  past_members_html[[index]] <- htmltools::div(
    htmltools::tags$li(past_members$`PAST MEMBERS`[index]),
    class = "g-col-12 g-col-md-3"
  )
}

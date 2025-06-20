# test the method for estimating biomass

# load the relevant libraries
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(ggbeeswarm)

# load companion scripts
source("code/functions/helpers.R")
source("code/functions/plot-theme.R")

# load libraries the InvAlloR library
library(InvAlloR)

# check if a figure folder exists
if (!dir.exists("manuscript/figures-tables")) {
  dir.create("manuscript/figures-tables")
}

# test 1: comparison with measured dry biomass values

# read the test data
dat <- readRDS("data/test_a_data_compilation.rds")
head(dat)
dim(dat)

output <-
  get_trait_from_taxon(
    data = dat,
    target_taxon = "taxon",
    life_stage = "life_stage",
    body_size = "length_mm",
    latitude_dd = "lat",
    longitude_dd = "lon",
    workflow = "best_fit",
    trait = "equation",
    max_tax_dist = 3.5,
    gen_sp_dist = 0.5
  )

# extract the data
output$decision_data |> View()
output <- output$data

# get proportion of names for which we do not have equations for
output |>
  dplyr::filter(is.na(id)) |>
  dplyr::pull(taxon) |>
  unique() |>
  length()/length(unique(output$taxon))

# remove rows where the dry-biomass is not there
output <-
  output |>
  dplyr::filter(!is.na(dry_biomass_mg))

# check how many unique taxa are left
length(unique(output$taxon))
nrow(output)

# how many unique taxa were there?
length(unique(dat$taxon))

# make a author_year - taxon combination column
output$group <- paste(output$reference, output$taxon, sep = "_")

# what's the minimum number in the output author_year column
output |>
  dplyr::group_by(group) |>
  dplyr::summarise(n = n())

# calculate percentage error for actual data
output <-
  output |>
  dplyr::mutate(error_perc = ((obs_dry_biomass_mg - dry_biomass_mg) / obs_dry_biomass_mg) * 100,
         abs_error_perc = (abs(obs_dry_biomass_mg - dry_biomass_mg) / obs_dry_biomass_mg) * 100,
         abs_error = (abs(obs_dry_biomass_mg - dry_biomass_mg)))

# check the distribution of error_perc
hist(output$error_perc)
hist(output$abs_error_perc)
hist(output$abs_error)

# check the summary statistics of error_perc
summary(output$error_perc)
summary(output$abs_error_perc)
summary(output$abs_error)

# how many data-points have more than 100 percent error
sum(output$abs_error_perc > 150)/nrow(output)

# null model i.e. order-level equations
order_null <- readr::read_csv("data/test_order_level_null_model.csv")

# check which orders there are
unique(order_null$order)
unique(output$order)

# calculate the order-level biomass from the input body lengths
output$order_dry_biomass_mg <- 
  
  mapply(function(x, y) {
    
    var1 <- y
    if (x %in% order_null[["order"]]) {
      equ <- parse(text = order_null[order_null[["order"]] == x, ][["equation"]])
      return(eval(equ))
    } else {
      return(NA)
    }
    
  }, output$order, output$length_mm, USE.NAMES = FALSE)

# calculate order-level absolute error
output <- 
  output |>
  dplyr::mutate(abs_error_perc_order = (abs(obs_dry_biomass_mg - order_dry_biomass_mg) / obs_dry_biomass_mg) * 100)

# compare error percentages
x <- output[!is.na(output$order_dry_biomass_mg), ]
x <- 
  tibble(method = c(rep("InvTraitR", nrow(x)), rep("Order", nrow(x))),
         abs_error_perc = c(x$abs_error_perc, x$abs_error_perc_order))

ggplot(data = x,
       mapping = aes(x = log(abs_error_perc), fill = method)) +
  geom_density(alpha = 0.2) +
  theme_test()

# what is the average error?
x |>
  dplyr::group_by(method) |>
  dplyr::summarise(mean_error = mean(abs_error_perc, na.rm = TRUE),
                   median_error = median(abs_error_perc, na.rm = TRUE),
                   min = min(abs_error_perc, na.rm = TRUE),
                   max = max(abs_error_perc, na.rm = TRUE)
                   )

# calculate the correlation per group
cor_df <- 
  output |>
  dplyr::group_by(order) |>
  dplyr::summarise(cor_obs_est = cor(log10(obs_dry_biomass_mg), log10(dry_biomass_mg) )) |>
  dplyr::mutate(cor_text = paste0("r = ", round(cor_obs_est, 2) ))

# plot dry weight inferred versus actual dry weight

# replace underscore with space in reference column
output$reference <- gsub(pattern = "_", " ", x = output$reference)

p1 <-
  ggplot() +
  geom_abline(
    intercept = 0, slope = 1,
    colour = "black", linetype = "dashed", linewidth = 0.5, alpha = 0.75) +
  geom_smooth(
    data = output,
    mapping = aes(
      x = log10(obs_dry_biomass_mg),
      y = log10(dry_biomass_mg), group = group, colour = reference),
    alpha = 1, linewidth = 0.25, method = "lm", se = FALSE, show.legend = FALSE) +
  geom_point(
    data = output,
    mapping = aes(
      x = log10(obs_dry_biomass_mg),
      y = log10(dry_biomass_mg), colour = reference),
    alpha = 0.5, shape = 16, size = 2.5, show.legend = TRUE) +
  geom_text(
    data = cor_df, 
    mapping = aes(x = -1.9, y = 2.7, label = cor_text),
    size = 4
  ) +
  guides(size = "none",
         colour = guide_legend(override.aes = list(size = 2.5,
                                                   alpha = 1,
                                                   shape = 16))) +
  ylab("Estimated dry biomass (mg, log10)") +
  xlab("Measured dry biomass (mg, log10)") +
  scale_colour_manual(values = wesanderson::wes_palette(name = "Darjeeling1", n = 10, "continuous")) +
  theme_meta() +
  facet_wrap(~order) +
  theme(strip.background = element_rect(fill = "white"),
        strip.text = element_text(colour = "black"),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 9),
        legend.key = element_rect(fill = NA),
        legend.spacing.x = unit(1, 'mm'),
        legend.spacing.y = unit(0.1, 'mm'))
plot(p1)

ggsave(filename = "manuscript/figures-tables/fig-5.png", p1,
       units = "cm", width = 18, height = 19, dpi = 600)


# test 2: comparison with equations selected by expert

# load the data
dat2 <- readRDS("data/test_b_data_compilation.rds")

# sample maximum five of the same taxon
dat2 <- 
  dat2 |>
  dplyr::group_by(reference, taxon, life_stage) |>
  dplyr::sample_n(size = ifelse(n() < 5, n(), 5)) |>
  dplyr::ungroup()
  
output2 <-
  get_trait_from_taxon(
    data = dat2,
    target_taxon = "taxon",
    life_stage = "life_stage",
    body_size = "length_mm",
    latitude_dd = "lat_dd",
    longitude_dd = "lon_dd",
    workflow = "best_fit",
    trait = "equation",
    max_tax_dist = 3.5,
    gen_sp_dist = 0.5
  )

# extract the relevant output
output2 <- output2$data

# get proportion of names for which we do not have equations for
output2 |>
  dplyr::filter(is.na(id)) |>
  dplyr::pull(taxon) |>
  unique() |>
  length()/length(unique(output2$taxon))

# check which taxa there were no equations for
output2 |>
  dplyr::select(reference, taxon, dry_biomass_mg,
                db_min_body_size_mm, length_mm, db_max_body_size_mm) |>
  dplyr::mutate(PA = ifelse(is.na(dry_biomass_mg), 0, 1 )) |>
  dplyr::select(-dry_biomass_mg) |>
  dplyr::distinct() |>
  View()

# remove rows where the dry-biomass is not there
output2 <-
  output2 |>
  dplyr::filter(!is.na(dry_biomass_mg))

# check how many unique taxa are left
length(unique(output2$taxon))
nrow(output2)

# what's the minimum number in the output author_year column
output2 |>
  dplyr::group_by(reference, taxon) |>
  dplyr::summarise(n = n())

# calculate percentage error for actual data
output2 <-
  output2 |>
  dplyr::mutate(error_perc = ((obs_dry_biomass_mg - dry_biomass_mg) / obs_dry_biomass_mg) * 100,
         abs_error_perc = (abs(obs_dry_biomass_mg - dry_biomass_mg) / obs_dry_biomass_mg) * 100,
         abs_error = (abs(obs_dry_biomass_mg - dry_biomass_mg)))

# get the correlation coefficient
cor_point <- cor(log10(output2$obs_dry_biomass_mg), log10(output2$dry_biomass_mg))
cor_point <- round(cor_point, 2)

# change Dolmans 2022 to Dolmans unpublished
output2$reference <- factor(output2$reference)
levels(output2$reference) <- c("Dolmans (unpublished)", "O'Gorman (2017)")

p2 <-
  ggplot() +
  geom_abline(
    intercept = 0, slope = 1,
    colour = "black", linetype = "dashed", linewidth = 0.5) +
  geom_point(
    data = output2,
    mapping = aes(
      x = log10(obs_dry_biomass_mg),
      y = log10(dry_biomass_mg), colour = reference),
    alpha = 0.5, shape = 16, size = 2.5, show.legend = TRUE,
    position = position_jitter(width = 0.05, height = 0.05)) +
  annotate(
    geom = "text", label = paste0("r = ", cor_point),
  x = -2.5, y = 0.5) +
  guides(size = "none",
         colour = guide_legend(override.aes = list(size = 3,
                                                   alpha = 1,
                                                   shape = 16))) +
  ylab("Estimated dry biomass (mg, log10)") +
  xlab("Expert dry biomass (mg, log10)") +
  scale_colour_manual(values = wesanderson::wes_palette(name = "Darjeeling1", n = 2)) +
  theme_meta() +
  theme(legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        legend.key = element_rect(fill = NA))
plot(p2)

ggsave(filename = "manuscript/figures-tables/fig-s2.png", p2, dpi = 400,
       units = "cm", width = 13.5, height = 9)

cor.test(log10(output2$obs_dry_biomass_mg), log10(output2$dry_biomass_mg))

### END

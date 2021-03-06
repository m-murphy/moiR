#' Dirichlet distribution
#'
#' @details Implementation of random sampling from a Dirichlet distribution
#'
#' @export
#'
#' @param n total number of draws
#' @param alpha vector controlling the concentration of simplex
rdirichlet <- function(n, alpha) {
  len_alpha <- length(alpha)
  d <- matrix(rgamma(len_alpha * n, alpha), ncol = len_alpha, byrow = TRUE)
  m <- d %*% rep(1, len_alpha)
  d / as.vector(m)
}


#' Simulate allele frequencies
#'
#' @details Simulate allele frequency vectors as a draw from a Dirichlet
#'  distribution
#'
#' @export
#'
#' @param alpha vector parameter controlling the Dirichlet distribution
#' @param num_loci total number of loci to draw
simulate_allele_frequencies <- function(alpha, num_loci) {
  dists <- rdirichlet(num_loci, alpha)
  lapply(seq_len(num_loci), function(x) {
    dists[x, ]
  })
}

#' Simulate sample COI
#'
#' @details Simulate sample COIs from a zero-truncated Poisson distribution
#'
#' @export
#'
#' @param num_samples the total number of biological samples to simulate
#' @param mean_coi mean multiplicity of infection
simulate_sample_coi <- function(num_samples, mean_coi) {
  qpois(runif(num_samples, dpois(0, mean_coi), 1), mean_coi)
}

#' Simulate sample genotype
#' @details Simulates sampling the genetics at a single locus given an allele
#'  frequency distribution and a vector of sample COIs
#'
#' @param sample_cois Numeric vector indicating the multiplicity of infection
#'  for each biological sample
#' @param locus_allele_dist Allele frequencies -- simplex parameter of a
#'  multinomial distribution
simulate_sample_genotype <- function(sample_cois, locus_allele_dist) {
  lapply(sample_cois, function(coi) {
    rmultinom(1, coi, locus_allele_dist)
  })
}

#' Simulates the observation process
#'
#' @details Takes a numeric value representing
#'  the number of strains contributing an allele and returns a binary vector
#'  indicating the presence or absence of the allele.
#'
#' @param alleles A numeric vector representing the number of strains
#'  contributing each allele
#' @param epsilon_pos false positive rate
#' @param epsilon_neg false negative rate
simulate_observed_allele <- function(alleles, epsilon_pos, epsilon_neg) {
  sapply(alleles, function(allele) {
    if (allele > 0) {
      rbinom(1, 1, prob = 1 - epsilon_neg)
    } else {
      rbinom(1, 1, epsilon_pos)
    }
  })
}

#' Simulate observed genotypes
#'
#' @details Simulate the observation process across a list of observation
#'  vectors
#'
#' @export
#'
#' @param true_genotypes a list of numeric vectors that are input
#'  to sim_observed_allele
#' @param epsilon_pos false positive rate
#' @param epsilon_neg false negative rate
simulate_observed_genotype <- function(true_genotypes,
                                       epsilon_pos,
                                       epsilon_neg) {
  lapply(true_genotypes, function(x) {
    simulate_observed_allele(x, epsilon_pos, epsilon_neg)
  })
}

#' Simulate data generated according to the assumed model
#'
#' @export
#'
#' @param mean_coi Mean multiplicity of infection drawn from a Poisson
#' @param locus_freq_alphas List of alpha vectors to be used to simulate
#'  from a Dirichlet distribution to generate allele frequencies.
#' @param num_samples Total number of biological samples to simulate
#' @param epsilon_pos False positive rate, between 0 and 1
#' @param epsilon_neg False negative rate, between 0 and 1
#' @return Simulated data that is structured to go into the MCMC sampler
#'
simulate_data <- function(mean_coi,
                          locus_freq_alphas,
                          num_samples,
                          epsilon_pos,
                          epsilon_neg) {
  allele_freq_dists <- c()

  for (alpha in locus_freq_alphas) {
    allele_freq_dists <- c(
      allele_freq_dists,
      simulate_allele_frequencies(alpha, 1)
    )
  }

  sample_cois <- simulate_sample_coi(num_samples, mean_coi)

  true_sample_genotypes <- lapply(allele_freq_dists, function(dist) {
    simulate_sample_genotype(sample_cois, dist)
  })

  observed_sample_genotypes <- lapply(
    true_sample_genotypes, function(locus_genotypes) {
      simulate_observed_genotype(locus_genotypes, epsilon_pos, epsilon_neg)
    }
  )

  list(
    data = observed_sample_genotypes,
    sample_ids = paste0("S", seq.int(1, num_samples)),
    loci = paste0("L", seq.int(1, length(locus_freq_alphas))),
    allele_freqs = allele_freq_dists,
    sample_cois = sample_cois,
    true_genotypes = true_sample_genotypes,
    input = list(
      mean_coi = mean_coi,
      locus_freq_alphas = locus_freq_alphas,
      num_samples = num_samples,
      epsilon_pos = epsilon_pos,
      epsilon_neg = epsilon_neg
    )
  )
}

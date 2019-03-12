#pragma once

#ifndef MCMC_UTILS_H_
#define MCMC_UTILS_H_

#include <Rcpp.h>
#include <R.h>

#define OVERFLO 1e100
#define UNDERFLO 1e-100

namespace UtilFunctions {
  int r_to_bool(SEXP x);

  int r_to_int(SEXP x);

  double r_to_double(SEXP x);

  std::string r_to_string(SEXP x);

  std::vector<bool> r_to_vector_bool(SEXP x);

  std::vector<int> r_to_vector_int(SEXP x);

  std::vector<double> r_to_vector_double(SEXP x);

  std::vector<std::string> r_to_vector_string(SEXP x);

  template <class T>
  std::vector<std::vector<T> > r_to_mat(Rcpp::List x);

  std::vector<std::vector<bool> > r_to_mat_bool(Rcpp::List x);

  std::vector<std::vector<int> > r_to_mat_int(Rcpp::List x);

  std::vector<std::vector<double> > r_to_mat_double(Rcpp::List x);

  template <class T>
  std::vector<std::vector<std::vector<T> > > r_to_array(Rcpp::List x);

  std::vector<std::vector<std::vector<bool> > > r_to_array_bool(Rcpp::List x);

  std::vector<std::vector<std::vector<int> > > r_to_array_int(Rcpp::List x);

  std::vector<std::vector<std::vector<double> > > r_to_array_double(Rcpp::List x);

  template <class T>
  void print(T x) {
    Rcpp::Rcout << x << "\n";
    R_FlushConsole();
  };

  template <class T1, class T2>
  void print(T1 x1, T2 x2) {
    Rcpp::Rcout << x1 << " " << x2 << "\n";
    R_FlushConsole();
  }

  template <class T1, class T2, class T3>
  void print(T1 x1, T2 x2, T3 x3) {
    Rcpp::Rcout << x1 << " " << x2 << " " << x3 << "\n";
    R_FlushConsole();
  }

  template <class T1, class T2, class T3, class T4>
  void print(T1 x1, T2 x2, T3 x3, T4 x4) {
    Rcpp::Rcout << x1 << " " << x2 << " " << x3 << " " << x4 << "\n";
    R_FlushConsole();
  }
  
  template <class T1, class T2, class T3, class T4, class T5>
  void print(T1 x1, T2 x2, T3 x3, T4 x4, T5 x5) {
    Rcpp::Rcout << x1 << " " << x2 << " " << x3 << " " << x4 << " " << x5 << "\n";
    R_FlushConsole();
  }
}


#endif // MCMC_UTILS_H_

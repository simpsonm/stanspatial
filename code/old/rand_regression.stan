data {
  int<lower = 1> n_obs;
  int<lower = 1> n_cov;
  int<lower = 1> n_group;
  vector[n_obs] y;
  matrix[n_obs, n_cov] x;
  int group[n_obs];
}
transformed data {
  vector[n_obs] y_cs;
  matrix[n_obs, n_cov] x_cs;

  // center and scale y
  y_cs = (y - mean(y))/sd(y);

  // center and scale x
  x_cs[,1] = x[,1];
  if(n_cov > 1){
    for(i in 2:n_cov){
      real x_mn; real x_sd;
      x_mn = mean(x[,i]);
      x_sd = sd(x[,i]);
      x_cs[,i] = (x[,i] - x_mn) / x_sd;
    }
  }
}
parameters {
  vector[n_cov] beta[n_group];
  real<lower = 0> sigma;
  vector[n_cov] mu_beta;
  vector<lower = 0>[n_cov] sigma_beta;
}
model {
  for(i in 1:n_obs){
    y_cs[i] ~ normal(x_cs[i]*beta[group[i]], sigma);
  }
  for(g in 1:n_group){
    beta[g] ~ normal(mu_beta, sigma_beta);
  }
  mu_beta ~ normal(0, 10);
  sigma_beta ~ student_t(5, 0, 10);
  sigma ~ student_t(5, 0, 10);
}

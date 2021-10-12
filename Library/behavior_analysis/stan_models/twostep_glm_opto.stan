// Stan code for a ridge regression glm model for opto data, splitting out the stimulation types

data {

	int<lower=0> nBack;
		
	real<lower=0,upper=1> pCong;
	
	int<lower=0> nTrials;
	int<lower=1,upper=2> choices[nTrials];
	int<lower=0,upper=1> commons[nTrials];
	int<lower=0,upper=1> rewards[nTrials];

	int<lower=0, upper=3> stims[nTrials+1]; // Three types of stimulation (full, reward, choice)
	
}

transformed data {

matrix[nTrials,nBack] reg_cr;
matrix[nTrials,nBack] reg_co;
matrix[nTrials,nBack] reg_ur;
matrix[nTrials,nBack] reg_uo;

reg_cr[1] =  rep_row_vector(0,nBack);
reg_co[1] =  rep_row_vector(0,nBack);
reg_ur[1] =  rep_row_vector(0,nBack);
reg_uo[1] =  rep_row_vector(0,nBack);

for (trial_i in 1:(nTrials-1)){
	int choice;
	int cr;
	int co;
	int ur;
	int uo; 
	
	// Set up the dummy variables
	cr =  0;
	co =  0;
	ur =  0;
	uo =  0;
	if (choices[trial_i] == 1){
	choice =  -1;
	}
	if (choices[trial_i] == 2){
	choice =  1;
	}
	
	// Populate the correct dummy vars
	if (commons[trial_i]==1){
		if (rewards[trial_i]==1){
			cr =  choice;
		}
		else if(rewards[trial_i]==0) {
			co =  choice;
		}
	}
	else if (commons[trial_i]==0) {
		if (rewards[trial_i]==1){
			ur =  choice;
		}
		else if(rewards[trial_i]==0) {
			uo =  choice;
		}
	}

	
	// Update the regressors using dummies
	reg_cr[trial_i+1,1] =  cr;
	reg_co[trial_i+1,1] =  co;
	reg_ur[trial_i+1,1] =  ur;
	reg_uo[trial_i+1,1] =  uo;
	for (nBack_i in 2:nBack){
		reg_cr[trial_i+1,nBack_i] =  reg_cr[trial_i,nBack_i-1];
		reg_co[trial_i+1,nBack_i] =  reg_co[trial_i,nBack_i-1];
		reg_ur[trial_i+1,nBack_i] =  reg_ur[trial_i,nBack_i-1];
		reg_uo[trial_i+1,nBack_i] =  reg_uo[trial_i,nBack_i-1];
	}
}






}

parameters {

vector[nBack] beta_cr_cntrl;
vector[nBack] beta_co_cntrl;
vector[nBack] beta_ur_cntrl;
vector[nBack] beta_uo_cntrl;
real beta_bias;

vector[nBack] beta_cr_rew;
vector[nBack] beta_co_rew;
vector[nBack] beta_ur_rew;
vector[nBack] beta_uo_rew;

vector[nBack] beta_cr_ch;
vector[nBack] beta_co_ch;
vector[nBack] beta_ur_ch;
vector[nBack] beta_uo_ch;

vector[nBack] beta_cr_both;
vector[nBack] beta_co_both;
vector[nBack] beta_ur_both;
vector[nBack] beta_uo_both;

}

transformed parameters {



}

model {



for(trial_i in 1:nTrials){
	real lin;
	real ll;
	int choice;
	int stim;

	stim =  stims[trial_i];
	
	if(stim==0){
		lin =  reg_cr[trial_i]*beta_cr_cntrl + reg_co[trial_i]*beta_co_cntrl + reg_ur[trial_i]*beta_ur_cntrl + reg_uo[trial_i]*beta_uo_cntrl + beta_bias;
	}
	else if(stim==1){
		lin =  reg_cr[trial_i]*beta_cr_rew + reg_co[trial_i]*beta_co_rew + reg_ur[trial_i]*beta_ur_rew + reg_uo[trial_i]*beta_uo_rew + beta_bias;
	}
	else if(stim==2){
		lin =  reg_cr[trial_i]*beta_cr_ch + reg_co[trial_i]*beta_co_ch + reg_ur[trial_i]*beta_ur_ch + reg_uo[trial_i]*beta_uo_ch + beta_bias;
	}
	else if(stim==3){
		lin =  reg_cr[trial_i]*beta_cr_both + reg_co[trial_i]*beta_co_both + reg_ur[trial_i]*beta_ur_both + reg_uo[trial_i]*beta_uo_both + beta_bias;
	}
	
	choice =  choices[trial_i] - 1;
	choice ~ bernoulli(inv_logit(lin));

}

// Priors
beta_cr_cntrl ~ normal(0,1);
beta_co_cntrl ~ normal(0,1);
beta_ur_cntrl ~ normal(0,1);
beta_uo_cntrl ~ normal(0,1);
beta_bias ~ normal(0,1);


beta_cr_rew ~ normal(beta_cr_cntrl, 1);
beta_co_rew ~ normal(beta_co_cntrl, 1);
beta_ur_rew ~ normal(beta_ur_cntrl, 1);
beta_uo_rew ~ normal(beta_uo_cntrl, 1);

beta_cr_ch ~ normal(beta_cr_cntrl, 1);
beta_co_ch ~ normal(beta_co_cntrl, 1);
beta_ur_ch ~ normal(beta_ur_cntrl, 1);
beta_uo_ch ~ normal(beta_uo_cntrl, 1);

beta_cr_both ~ normal(beta_cr_cntrl, 1);
beta_co_both ~ normal(beta_co_cntrl, 1);
beta_ur_both ~ normal(beta_ur_cntrl, 1);
beta_uo_both ~ normal(beta_uo_cntrl, 1);



}


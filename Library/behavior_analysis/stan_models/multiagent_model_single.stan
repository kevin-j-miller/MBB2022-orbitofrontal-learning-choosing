// STAN code for FLAT version of multiagent model

// Contains:
// 1) Model-Based
// 2) Model-Free
// 3) CS/US Bonus
// 4) WS/LS MB
// 5) WS/LS MF
// 6) Perseveration
// 7) Bias


data {
	real<lower=0,upper=1> pCong;
	
	int<lower=0> nTrials;
	int<lower=1,upper=2> choices[nTrials];
	int<lower=1,upper=2> outcomes[nTrials];
	int<lower=0,upper=1> rewards[nTrials];

	int<lower=0,upper=1> inc[8]; // Use this variable to include or exclude each of the various Q's. 
	
}


parameters {
	
	
	// 1) Model-Based
	real<lower=0, upper=1> alphaMB;
	real<lower=0, upper=1> alphaT;
	real betaMB;
	
	// 2) Model-Free
	real<lower=0, upper=1> alphaMF;
	
	real<lower=0, upper=1> lambda;
	
	real betaMF;
	
	// 3) CS/US Bonus
	real betaBonus;
	
	// 4) WS/LS MB
	real betaWslsMB;
	
	// 5) WS/LS MF
	real betaWslsMF;
	
	// 6) Perseveration
	real betaPersev;
	
	// 7) Bias
	real betaBias;
	
}

transformed parameters {

	real log_probs;

	// Transformed parameters for each system
		
		// 1) Model-Based
		real betaMB_norm;
		// 2) Model-Free
		real betaMF_norm;
		// 3) CS/US Bonus
		real betaBonus_norm;
		// 4) WS/LS MB
		real betaWslsMB_norm;
		// 5) WS/LS MF
		real betaWslsMF_norm;
		// 6) Perseveration
		real betaPersev_norm;
		// 7) Bias
	
		
	// Compute the log_prob
		log_probs <- 0;

		{
		// Internal value functions
		row_vector[2] q_eff;
		row_vector[2] q2_mb;
		row_vector[2] q1_mb;
		row_vector[2] q2_mf;
		row_vector[2] q1_mf;
		row_vector[2] q_bonus;
		row_vector[2] q_wslsMB;
		row_vector[2] q_wslsMF;
		row_vector[2] q_persev;
		row_vector[2] q_bias;

		// Other internal variables (helpers)
		int reward;
		int outcome;
		int nonoutcome;
		int choice;
		int nonchoice;
		int common;
		real alphaT_eff;
		
		// Value function trackers
		real q1_mb_sum;
		real q1_mb_sum_sq;
		real q1_mf_sum;
		real q1_mf_sum_sq;
		real q_bonus_sum;
		real q_bonus_sum_sq;
		real q_WslsMB_sum;
		real q_WslsMB_sum_sq;
		real q_WslsMF_sum;
		real q_WslsMF_sum_sq;
		real q_persev_sum;
		real q_persev_sum_sq;
		matrix[2,2] T;

		
		int nTrials_rat;

		
		q1_mb_sum <- 0;
		q1_mb_sum_sq <- 0;
		q1_mf_sum <- 0;
		q1_mf_sum_sq <- 0;
		q_bonus_sum <- 0;
		q_bonus_sum_sq <- 0;
		q_WslsMB_sum <- 0;
		q_WslsMB_sum_sq <- 0;
		q_WslsMF_sum <- 0;
		q_WslsMF_sum_sq <- 0;
		q_persev_sum <- 0;
		q_persev_sum_sq <- 0;
	
		alphaT_eff <- alphaT*inc[8];
		nTrials_rat  <- 0;
		
		// Compute the value functions
		
		for (trial_i in 1:nTrials) {
			
			// Check if we need to move to the next rat
			if (trial_i==1){
			// If we're on a new rat, reinitialize the values
			q2_mb[1] <- 0.5; 				q2_mb[2] <- 0.5;
			q2_mf[1] <- 0.5; 				q2_mf[2] <- 0.5;
			q1_mf[1] <- 0.5; 				q1_mf[2] <- 0.5;
			q_bonus[1] <- 0.5;				q_bonus[2] <- 0.5;
			q_wslsMB[1] <- 0.5; 			q_wslsMB[2] <- 0.5;
			q_wslsMF[1] <- 0.5; 			q_wslsMF[2] <- 0.5;
			q_persev[1] <- 0.5;				q_persev[2] <- 0.5;
			q_bias[1] <- betaBias;		q_bias[2] <- -1*betaBias;		
			T[1,1] <- pCong; 		T[1,2] <- (1-pCong);	
			T[2,1] <- (1-pCong); 	T[2,2] <- pCong;			
			}
					
			// Compute MB values for step 1
			// Probability of choice
			q1_mb[1] <- T[1,1]*q2_mb[1] + T[1,2]*q2_mb[2];
			q1_mb[2] <- T[2,1]*q2_mb[1] + T[2,2]*q2_mb[2];
			
			// Update var trackers
			q1_mb_sum <- q1_mb_sum + (q1_mb[1]);
			q1_mb_sum_sq <- q1_mb_sum_sq + (q1_mb[1])^2;
			
			q1_mf_sum <- q1_mf_sum + (q1_mf[1]);
			q1_mf_sum_sq <- q1_mf_sum_sq + (q1_mf[1])^2;
			
			q_bonus_sum <- q_bonus_sum + (q_bonus[1]);
			q_bonus_sum_sq <- q_bonus_sum_sq + (q_bonus[1])^2;
			
			q_WslsMB_sum <- q_WslsMB_sum + (q_wslsMB[1]);
			q_WslsMB_sum_sq <- q_WslsMB_sum_sq + (q_wslsMB[1])^2;
			
			q_WslsMF_sum <- q_WslsMF_sum + (q_wslsMF[1]);
			q_WslsMF_sum_sq <- q_WslsMF_sum_sq + (q_wslsMF[1])^2;
			
			q_persev_sum <- q_persev_sum + (q_persev[1]);
			q_persev_sum_sq <- q_persev_sum_sq + (q_persev[1])^2;
		
			nTrials_rat <- nTrials_rat + 1;
		
			// Compute log_prob for this trial
			q_eff <- betaMB*q1_mb*inc[1] + betaMF*q1_mf*inc[2] + betaBonus*q_bonus*inc[3] + betaWslsMB*q_wslsMB*inc[4] + betaWslsMF*q_wslsMF*inc[5] + betaPersev*q_persev*inc[6] + q_bias*inc[7];
			log_probs <- log_probs + categorical_log(choices[trial_i] , softmax(to_vector(q_eff)));
			
			// Do the learning
			outcome <- outcomes[trial_i];
			nonoutcome <- 3 - outcome; // convert 2's into 1's, 1's into 2's 

			choice <- choices[trial_i];
			nonchoice <- 3 - choice;
			
			reward <- rewards[trial_i];
			
			if (pCong > 0.5) {
				if (choice == outcome) {
					common <- 1;
				}
				else {
					common <- 0;
				}
			}
			else {
				if (choice == outcome) {
					common <- 0;
				}
				else {
					common <- 1;
				}
			}
			
			// MB learning
			q2_mb[outcome] <- q2_mb[outcome] + alphaMB*(reward - q2_mb[outcome]);
			q2_mb[nonoutcome] <- q2_mb[nonoutcome] + alphaMB*(1 - reward - q2_mb[nonoutcome]);
			
			// T Learning
			T[choice,outcome] <- T[choice,outcome]*(1-alphaT_eff) + alphaT_eff;
			T[choice,nonoutcome] <- T[choice,nonoutcome]*(1-alphaT_eff);
			
			// MF Learning
			q2_mf[outcome] <- q2_mf[outcome] + alphaMF*(reward - q2_mf[outcome]);
			q2_mf[nonoutcome] <- q2_mf[nonoutcome] + alphaMF*(1 - reward - q2_mf[nonoutcome]);
			
			q1_mf[choice] <- q1_mf[choice] + alphaMF*(q2_mf[outcome] - q1_mf[choice]) + alphaMF*lambda*(reward - q2_mf[outcome]);
		
		//	q1_mf[choice] <- q1_mf[choice] + alphaMF*(reward - q1_mf[choice]);
		//	q1_mf[nonchoice] <- q1_mf[nonchoice] + alphaMF*(1 - reward - q1_mf[nonchoice]);
		
		
			// Bonus Learning
			if (common == 1) {
			q_bonus[choice]<- 1;	q_bonus[nonchoice] <- 0;
			}
			else {
			q_bonus[choice]<- 0;	q_bonus[nonchoice] <- 1;
			}
			
			// WSLS learning
			if (reward==1) {
				q_wslsMF[choice] <- 1;  q_wslsMF[nonchoice] <- 0;
				if (common==1) {
					q_wslsMB[choice] <- 1;  q_wslsMB[nonchoice] <- 0;
				}
				else {
					q_wslsMB[choice] <- 0;  q_wslsMB[nonchoice] <- 1;
				}				
			}
			else {
				q_wslsMF[choice] <- 0;  q_wslsMF[nonchoice] <- 1;
				if (common==1) {
					q_wslsMB[choice] <- 0;  q_wslsMB[nonchoice] <- 1;
				}
				else {
					q_wslsMB[choice] <- 1;  q_wslsMB[nonchoice] <- 0;
				}
			}
			
			// Persev learning
			q_persev[choice]<- 1;	q_persev[nonchoice] <- 0;
			
		}
		
		// Calculate VAR

		{
			real qSTD_mb;
			real qSTD_mf;
			real qSTD_bonus;
			real qSTD_WslsMB;
			real qSTD_WslsMF;
			real qSTD_persev;
			
			
			qSTD_mb <- sqrt((q1_mb_sum_sq - q1_mb_sum^2/nTrials_rat)/(nTrials_rat-1));
			qSTD_mf <- sqrt((q1_mf_sum_sq - q1_mf_sum^2/nTrials_rat)/(nTrials_rat-1));
			qSTD_bonus <- sqrt((q_bonus_sum_sq - q_bonus_sum^2/nTrials_rat)/(nTrials_rat-1));
			qSTD_WslsMB <- sqrt((q_WslsMB_sum_sq - q_WslsMB_sum^2/nTrials_rat)/(nTrials_rat-1));
			qSTD_WslsMF <- sqrt((q_WslsMF_sum_sq - q_WslsMF_sum^2/nTrials_rat)/(nTrials_rat-1));
			qSTD_persev <- sqrt((q_persev_sum_sq - q_persev_sum^2/nTrials_rat)/(nTrials_rat-1));
			

		// Normalize Betas by Standard Deviation
		betaMB_norm <- betaMB .* qSTD_mb;
		betaMF_norm <- betaMF .* qSTD_mf;
		betaBonus_norm <- betaBonus .* qSTD_bonus;
		betaWslsMB_norm <- betaWslsMB .* qSTD_WslsMB;
		betaWslsMF_norm <- betaWslsMF .* qSTD_WslsMF;
		betaPersev_norm <- betaPersev .* qSTD_persev;
		}
}
}

model {

	// Population priors
		// 1) Model-Based
		
		alphaMB ~ beta(3,3);
		alphaT ~ beta(3,3);
				
		
		// 2) Model-Free
		
		alphaMF ~ beta(3,3);
		
		
		lambda ~ beta(3,3);
		
		
		
		// 3) CS/US Bonus
		
		
		// 4) WS/LS MB
		
		
		// 5) WS/LS MF
		
		
		// 6) Perseveration
		
		
		// 7) Bias
		
		
	// Draw subject parameters
		// 1) Model-Based
		betaMB_norm ~ normal(0, 0.5);
		// 2) Model-Free
		betaMF_norm ~ normal(0, 0.5);
		// 3) CS/US Bonus
		betaBonus_norm ~ normal(0, 0.5);
		// 4) WS/LS MB
		betaWslsMB_norm ~ normal(0, 0.5);
		// 5) WS/LS MF
		betaWslsMF_norm ~ normal(0, 0.5);
		// 6) Perseveration
		betaPersev_norm ~ normal(0, 0.5);
		// 7) Bias
		betaBias ~ normal(0, 0.5);
		
	// Data likelihood
	increment_log_prob((log_probs));
	

}
function d = d_prime(sample1, sample2)

d = (mean(sample1) - mean(sample2)) ./ sqrt(0.5 * (sem(sample1).^2 + sem(sample2).^2));

end
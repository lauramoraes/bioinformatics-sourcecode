left = mvnrnd([1 1], [1 1], 5);
right = mvnrnd([4 4], [1 1], 15);

scatter(left(:,1), left(:,2), 'x');
hold on;
scatter(right(:,1), right(:,2));

%left = [-0.0891    1.0859; 1.0326   -0.4916; 1.5525    0.2577; 2.1006   -0.0616; 2.5442    3.3505;   4.1978    2.0670; 3.2352    2.8342; 2.5776    4.1049]
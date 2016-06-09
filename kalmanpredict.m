function pos = kalmanpredict(oldpos1,oldpos2)

param = getDefaultParameters();
param.initialEstimateError = param.initialEstimateError(1:2);
param.motionNoise          = param.motionNoise(1:2);
initialLocation = oldpos2;
kalmanFilter = configureKalmanFilter(param.motionModel, ...
          initialLocation, param.initialEstimateError, ...
          param.motionNoise, param.measurementNoise);
predict(kalmanFilter);
pos = correct(kalmanFilter, oldpos1);

end

function param = getDefaultParameters()
  param.motionModel           = 'ConstantVelocity';
  param.initialLocation       = [0 0];
  param.initialEstimateError  = 1E5 * ones(1, 3);
  param.motionNoise           = [25, 10, 1];
  param.measurementNoise      = 25;
  param.segmentationThreshold = 0.05;
end
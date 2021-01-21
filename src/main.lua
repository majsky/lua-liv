local import = require("liv.import")
for k, v in pairs(import("GAN.CSV")) do
  print(k,v)
end

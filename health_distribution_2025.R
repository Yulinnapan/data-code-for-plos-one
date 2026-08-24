# ==========================================
# 基于马尔可夫模型预测2025年人口健康分布
# 基期：2018年（Table 7），转移矩阵：Table 6
# 逻辑：初始向量 × P^7，剔除Death后归一化
# ==========================================

# ---- 1. 2018年初始健康状态分布（Table 7，不含Death）----
# 假设初始人口均存活（Death=0），对应1965年及以后出生人口
pi0 <- c(
  Healthy  = 0.267801444,
  Mild     = 0.661973086,
  Moderate = 0.039836022,
  Severe   = 0.030389448,
  Death    = 0.000000000   # 基期无死亡
)

cat("初始状态向量（2018年）:\n")
print(pi0)
cat("行和:", sum(pi0), "\n\n")

# ---- 2. 一年期健康转移矩阵（Table 6）----
P <- matrix(c(
  0.684213, 0.295927, 0.005443, 0.001561, 0.012857,
  0.085023, 0.858074, 0.027890, 0.009156, 0.019857,
  0.017529, 0.302033, 0.498802, 0.118533, 0.063103,
  0.007132, 0.037189, 0.099237, 0.660993, 0.195449,
  0.000000, 0.000000, 0.000000, 0.000000, 1.000000
), nrow = 5, byrow = TRUE,
   dimnames = list(
     c("Healthy","Mild","Moderate","Severe","Death"),
     c("Healthy","Mild","Moderate","Severe","Death")
   ))

cat("一年期转移矩阵 P:\n")
print(round(P, 6))
cat("行和:", rowSums(P), "\n\n")

# ---- 3. 计算 P^7（2018 → 2025，转移7次）----
P7 <- P
for (i in 2:7) P7 <- P7 %*% P

cat("P^7（7年累积转移矩阵）:\n")
print(round(P7, 6))
cat("\n")

# ---- 4. 预测2025年状态分布 ----
pi2025 <- pi0 %*% P7
cat("2025年状态分布（含Death）:\n")
print(round(pi2025, 6))
cat("合计:", sum(pi2025), "\n\n")

# ---- 5. 条件分布：剔除Death后归一化（对应Table 8格式）----
pi2025_alive <- pi2025[, c("Healthy","Mild","Moderate","Severe")]
pi2025_norm  <- as.numeric(pi2025_alive) / sum(pi2025_alive)
names(pi2025_norm) <- c("Healthy","Mild","Moderate","Severe")

cat("==========================================\n")
cat("2025年健康分布预测（Table 8，剔除Death后归一化）:\n")
cat("==========================================\n")
result <- data.frame(
  Healthy  = round(pi2025_norm["Healthy"],  6),
  Mild     = round(pi2025_norm["Mild"],     6),
  Moderate = round(pi2025_norm["Moderate"], 6),
  Severe   = round(pi2025_norm["Severe"],   6)
)
print(result)




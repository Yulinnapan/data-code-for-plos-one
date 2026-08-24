# =============================================================
# 从三年期转移矩阵推导一年期转移矩阵
# 方法：矩阵对数法（与论文一致）
#   P1 = expm( logm(P3) / 3 )
# 状态：Healthy / Mild / Moderate / Severe / Death
# =============================================================

# ---- 0. 安装 / 加载依赖 ----------------------------------------
if (!requireNamespace("expm", quietly = TRUE))
  install.packages("expm", repos = "https://cloud.r-project.org")
library(expm)   # 提供 logm() 和 expm()

# ---- 1. 输入：三年期转移矩阵 P3 --------------------------------

states <- c("Healthy", "Mild", "Moderate", "Severe", "Death")

P3 <- matrix(c(
  0.376849, 0.543791, 0.023409, 0.010330, 0.045622,
  0.156397, 0.712360, 0.043480, 0.023372, 0.064391,
  0.073715, 0.460366, 0.160095, 0.128525, 0.177300,
  0.022688, 0.132081, 0.105055, 0.311407, 0.428769,
  0.000000, 0.000000, 0.000000, 0.000000, 1.000000
), nrow = 5, byrow = TRUE,
   dimnames = list(states, states))

cat("===== 三年期转移矩阵 P3 =====\n")
print(round(P3, 6))
cat("行和:", round(rowSums(P3), 8), "\n\n")

# ---- 2. 计算生成元矩阵 Q = logm(P3) ----------------------------
Q <- logm(P3)

max_imag <- max(abs(Im(Q)))
cat("logm 虚部最大值（应接近 0）:", max_imag, "\n")
if (max_imag > 1e-8)
  warning("虚部较大，请检查 P3 是否为合法转移矩阵！")

Q <- Re(Q)   # 取实部
cat("生成元矩阵 Q 行和（应接近 0）:", round(rowSums(Q), 8), "\n\n")

# ---- 3. 一年期生成元 Q1 = Q / 3 --------------------------------
Q1 <- Q / 3

# ---- 4. 一年期转移矩阵 P1 = expm(Q1) --------------------------
P1 <- expm(Q1)
dimnames(P1) <- list(states, states)

cat("===== 一年期转移矩阵 P1 =====\n")
print(round(P1, 6))
cat("行和:", round(rowSums(P1), 8), "\n\n")

# ---- 5. 验证：P1^3 应还原 P3 ----------------------------------
P1_cubed <- P1 %*% P1 %*% P1
max_err   <- max(abs(P1_cubed - P3))
cat("验证 P1^3 ≈ P3，最大绝对误差:", max_err, "\n")
if (max_err < 1e-8) {
  cat("✓ 验证通过（误差在机器精度级别）\n\n")
} else {
  warning("误差较大，请检查输入矩阵！")
}

# ---- 6. 导出结果 -----------------------------------------------
write.csv(round(as.data.frame(P1), 6), "P1_annual_matrix.csv")
cat("一年期矩阵已导出至 P1_annual_matrix.csv\n")

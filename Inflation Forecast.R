# ==========================================
# 通货膨胀率预测：基于均值回归的动态调整模型
# ==========================================

library(ggplot2)
library(gridExtra)
library(moments)
library(tseries)

# 1. 数据准备 (截取2011-2023)
years <- 2011:2023
inflation_rate <- c(5.40, 2.60, 2.60, 2.0,
                    1.40, 2.0, 1.60, 2.10, 2.90,
                    2.50, 0.90, 2.0, 0.20)

cat("==========================================\n")
cat("通货膨胀率研究：均值回归模型分析报告\n")
cat("==========================================\n\n")

# ==========================================
# 2. 参数设定（与医疗通胀率模型逻辑完全一致）
# ==========================================
# 长期均衡值 μ：全样本均值
mu_inf <- mean(inflation_rate)
# 调整速度 θ：严格锁定为 0.18
theta_lock <- 0.18
half_life_inf <- log(0.5) / log(1 - theta_lock)

cat("[一、模型参数设定]\n")
cat(sprintf("长期均衡水平 μ (通货膨胀率): %.4f%%\n", mu_inf))
cat(sprintf("调整速度 θ (锁定): %.3f\n", theta_lock))
cat(sprintf("半衰期: %.1f 年\n\n", half_life_inf))

# ==========================================
# 3. ACF 自相关分析（学术细柱风格）
# ==========================================
acf_inf_res <- acf(inflation_rate, plot = FALSE)
acf_inf_df  <- data.frame(Lag = acf_inf_res$lag, ACF = acf_inf_res$acf)
ci_inf <- qnorm((1 + 0.95) / 2) / sqrt(length(inflation_rate))

p_acf_inf <- ggplot(acf_inf_df, aes(x = Lag, y = ACF)) +
  geom_bar(stat = "identity", width = 0.05, fill = "black") +
  geom_hline(yintercept = c(ci_inf, -ci_inf),
             linetype = "dashed", color = "black") +
  geom_hline(yintercept = 0, color = "black") +
  scale_x_continuous(breaks = 0:10) +
  labs(title = "图1: 通货膨胀率自相关函数 (ACF)",
       x = "滞后阶数 (Lag)", y = "ACF") +
  theme_bw() +
  theme(plot.title   = element_text(hjust = 0.5, face = "bold"),
        panel.grid   = element_blank())
print(p_acf_inf)

# ==========================================
# 4. 残差诊断检验
# ==========================================
fitted_inf  <- numeric(length(inflation_rate) - 1)
actual_inf  <- inflation_rate[-1]

for (i in 2:length(inflation_rate)) {
  # y(t) = y(t-1) - θ * [y(t-1) - μ]
  fitted_inf[i - 1] <- inflation_rate[i - 1] -
    theta_lock * (inflation_rate[i - 1] - mu_inf)
}
residuals_inf <- actual_inf - fitted_inf

cat("[二、残差诊断结果]\n")
shapiro_inf <- shapiro.test(residuals_inf)
cat(sprintf("Shapiro-Wilk 正态性  p-value: %.4f\n", shapiro_inf$p.value))
lb_inf <- Box.test(residuals_inf, lag = 3, type = "Ljung-Box")
cat(sprintf("Ljung-Box   独立性  p-value: %.4f\n\n", lb_inf$p.value))

# MAE
mae_inf <- mean(abs(residuals_inf))
cat(sprintf("MAE（平均绝对误差）: %.4f%%\n\n", mae_inf))

# 残差分布图
res_inf_df <- data.frame(Year = years[-1], Residuals = residuals_inf)
p_res_inf <- ggplot(res_inf_df, aes(x = Year, y = Residuals)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(size = 3) +
  labs(title = "图2: 通货膨胀模型残差分布",
       x = "年份", y = "残差 (%)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p_res_inf)

# ==========================================
# 5. 递归预测 (2025-2029)
# ==========================================
forecast_steps    <- 2024:2029
forecast_inf_all  <- numeric(length(forecast_steps))
current_val_inf   <- tail(inflation_rate, 1)   # 2023年值作为起点

for (i in 1:length(forecast_steps)) {
  current_val_inf    <- current_val_inf - theta_lock * (current_val_inf - mu_inf)
  forecast_inf_all[i] <- current_val_inf
}

# 提取 2025-2029 预测结果（跳过2024，取索引2:6）
forecast_inf_res <- data.frame(
  年份           = 2025:2029,
  通胀率预测值   = round(forecast_inf_all[2:6], 4)
)

cat("[三、2025-2029 预测结果汇总]\n")
print(forecast_inf_res)

# ==========================================
# 6. 最终趋势可视化
# ==========================================
plot_inf_df <- data.frame(
  Year  = c(years, 2025:2029),
  Value = c(inflation_rate, forecast_inf_all[2:6]),
  Type  = c(rep("历史观测", length(years)),
            rep("均值回归预测", 5))
)

p_trend_inf <- ggplot(plot_inf_df, aes(x = Year, y = Value)) +
  geom_line(data = subset(plot_inf_df, Type == "历史观测"),
            linetype = "solid", color = "black", linewidth = 1) +
  geom_line(data = subset(plot_inf_df, Type == "均值回归预测"),
            linetype = "dashed", color = "red", linewidth = 1) +
  geom_point(aes(shape = Type, color = Type), size = 3) +
  geom_hline(yintercept = mu_inf,
             linetype = "dotted", color = "gray40") +
  annotate("text", x = 2011.5, y = mu_inf + 0.15,
           label = paste0("μ = ", round(mu_inf, 2), "%"),
           color = "gray40", size = 3.5) +
  scale_color_manual(values = c("历史观测"   = "black",
                                "均值回归预测" = "red")) +
  scale_shape_manual(values = c("历史观测"   = 16,
                                "均值回归预测" = 17)) +
  labs(title    = "图3: 通货膨胀率趋势预测 (2025-2029)",
       subtitle = paste0("基于固定参数 θ = 0.18, μ = ",
                         round(mu_inf, 2), "%"),
       x = "年份", y = "通货膨胀率 (%)",
       color = NULL, shape = NULL) +
  theme_bw() +
  theme(legend.position = "bottom",
        plot.title      = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle   = element_text(hjust = 0.5))
print(p_trend_inf)
function normalizeRevenue(raw) {
  return {
    businessId: raw.businessId,
    month: raw.month,
    revenue: Number(raw.revenue).toFixed(2),
    refunds: Number(raw.refunds || 0).toFixed(2),
    netRevenue: (Number(raw.revenue) - Number(raw.refunds || 0)).toFixed(2)
  };
}

function normalizeCogs(raw) {
  const total = raw.cogsItems.reduce((acc, item) => acc + Number(item.cost), 0);
  
  return {
    businessId: raw.businessId,
    month: raw.month,
    cogsItems: raw.cogsItems.map(item => ({
      sku: item.sku,
      description: item.description || "",
      cost: Number(item.cost).toFixed(2)
    })),
    totalCogs: total.toFixed(2)
  };
}

function normalizeExpenses(raw) {
  const total = raw.expenseItems.reduce((acc, item) => acc + Number(item.cost), 0);

  return {
    businessId: raw.businessId,
    month: raw.month,
    expenseItems: raw.expenseItems.map(item => ({
      category: item.category,
      description: item.description || "",
      cost: Number(item.cost).toFixed(2)
    })),
    totalExpenses: total.toFixed(2)
  };
}

module.exports = {
  normalizeRevenue,
  normalizeCogs,
  normalizeExpenses
};

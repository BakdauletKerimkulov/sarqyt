import { defineConfig } from "vitest/config";

// Тесты берём только из исходников. Без явного include vitest подхватывает
// ещё и скомпилированные lib/**/*.test.js, которые tsc кладёт рядом с кодом:
// это CommonJS, и vitest на них падает с "cannot be imported in a CommonJS module".
// tsconfig.json теперь исключает тесты из сборки, но include защищает и от
// уже лежащих в lib/ артефактов старых сборок.
export default defineConfig({
  test: {
    include: ["src/**/*.test.ts", "test/**/*.test.ts"],
    exclude: ["lib/**", "node_modules/**"],
  },
});

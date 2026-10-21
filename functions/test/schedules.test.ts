import { readFileSync, readdirSync, statSync } from "fs";
import { resolve, join } from "path";
import { describe, it, expect } from "vitest";

const SRC_DIR = resolve(__dirname, "../src");

/**
 * Все .ts в src, кроме тестов.
 * @param {string} dir Каталог, который обходим рекурсивно.
 * @return {string[]} Пути найденных файлов.
 */
function sourceFiles(dir: string): string[] {
  return readdirSync(dir).flatMap((entry) => {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) return sourceFiles(full);
    if (!full.endsWith(".ts") || full.endsWith(".test.ts")) return [];
    return [full];
  });
}

/**
 * Текст каждого вызова onSchedule(...) до начала обработчика.
 * @param {string} source Содержимое файла.
 * @return {string[]} Аргументы найденных вызовов.
 */
function scheduleCalls(source: string): string[] {
  return [...source.matchAll(/onSchedule\(([\s\S]*?)async\s*\(/g)].map(
    (match) => match[1]
  );
}

describe("scheduled function options", () => {
  const files = sourceFiles(SRC_DIR).filter((file) =>
    readFileSync(file, "utf8").includes("onSchedule(")
  );

  it("finds the scheduled functions to check", () => {
    // Страховка от молча пустого прогона, если разбор сломается.
    expect(files.length).toBeGreaterThanOrEqual(4);
  });

  it("declares an explicit timeZone on every wall-clock schedule", () => {
    // "every day HH:MM" без timeZone молча означает UTC — и читатель
    // не может отличить намеренный UTC от забытого пояса. Интервальные
    // расписания ("every N minutes") от пояса не зависят.
    const offenders: string[] = [];

    for (const file of files) {
      for (const call of scheduleCalls(readFileSync(file, "utf8"))) {
        if (!call.includes("every day")) continue;
        if (call.includes("timeZone")) continue;
        offenders.push(file.replace(`${SRC_DIR}/`, ""));
      }
    }

    expect(offenders).toEqual([]);
  });
});
